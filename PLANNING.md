# PLANNING — Lord of Gyms Member

Read this at the start of every session. It is the architectural contract.
Product context: `../logfitness_saas/docs/PRD.md`. Backend contract: `../logfitness_saas/PLANNING.md`. Style and code reference: `../logfitness_flutter`. Work queue: `TASKS.md`.

---

## 1. What this is

The **members' app** for one gym — Lord of Gyms Fitness (LOG), Hetauda. One Flutter binary, one role (member), one Supabase project: the same Postgres that backs the staff web console (`logfitness_saas`) and the staff app (`logfitness_flutter`, "Gym Tross"). There is no separate backend and no bespoke API beyond the Edge Functions listed in §5.

**Decision of 2026-11-09:** Gym Tross is the **management app** (the SaaS product). Members get their own app; the member shell inside Gym Tross is removed once this one ships (`TASKS.md` Phase 8). Today that shell already works — home, QR check-in, classes, bookings, payments, messages, profile — and is the source this app is ported from.

A member opens it to see: *is my membership active, how many days are left, what is my card number, do I owe anything* — and to show a QR at the door, book a class, read messages from the gym, and **ask the front desk to renew**. Renewal is a request, not a payment: the desk calls them and renews at the counter, exactly as for the public balance page (`lordofgyms.com/balance?card_no=0004`), which this app supersedes for members who install it.

**Branding:** LOG-branded (name, icon, colours). The org is fixed at build time (`ORG_SLUG`); the member never picks a gym. A white-label build for another gym is a later, explicit decision.

**Languages:** English and Nepali from the first build. Members are not trained users; the gym's SMS templates are already bilingual.

---

## 2. Stack

| Layer | Choice | Notes |
| --- | --- | --- |
| SDK | Flutter 3.38 / Dart 3.10 | Same as the staff app. Pin the constraint in `pubspec.yaml`. No fvm, no melos. |
| Backend | `supabase_flutter` | PostgREST + Auth + (later) Realtime. Same project as the console and Gym Tross. |
| State + DI | `flutter_riverpod` + `riverpod_annotation` | Codegen providers. No service locator. |
| Routing | `go_router` | One auth redirect guard. No role branching — there is one role. |
| Models | `freezed` + `json_serializable` | Generated, committed. Unknown JSON keys are ignored so an additive backend change never breaks a shipped build. |
| Session storage | `flutter_secure_storage` | Refresh token only. The PIN is never stored (see §4). |
| QR | `qr_flutter` | Renders the minted check-in token. |
| i18n | Flutter `gen-l10n` (`.arb`, `en` + `ne`) | Every string. Dates/numbers via `intl`, in the org's timezone. |
| Push | `firebase_core` + `firebase_messaging` | **Its own Firebase project** for this bundle id. Not wired until Phase 7. |
| Preferences | `shared_preferences` | Theme mode, language override. |
| Lints / CI | `flutter_lints`, `riverpod_lint`, `custom_lint` | CI: pub get, build_runner, generated-files check, analyze, custom_lint, test. |

Anything not in this table is undecided. Add it here before adding it to `pubspec.yaml`.

**Reuse:** member code is **copied** from the staff app (`lib/features/member/**`, `lib/data/{qr,classes,payments,notifications}/**`, formatters, `AppFailure`, `repository_guard`). There is **no shared package in v1** — two small apps drifting for a quarter is cheaper than a package boundary. When a fix lands in a copied file, note it in `TASKS.md` Discovered so the other copy is not forgotten.

**Identifiers (placeholders until Phase 8 confirms them):** Dart package `logfitness_membership_flutter`; bundle id / applicationId `com.lordofgyms.member`; store name "LOG Fitness". Gym Tross stays `com.gymtross.app`.

---

## 3. Architecture rules — non-negotiable

- **Layer-first folders, a module inside each layer:**
  `lib/app/` (app, router, theme, brand, startup failure) · `lib/supabase/` (config, bootstrap, providers, claims, secure storage) · `lib/data/<module>/` (repositories + freezed models: auth, member, memberships, invoices, payments, classes, attendance, qr, notifications, renewal, push) · `lib/domain/` (enums, errors, formatters, validation) · `lib/features/<module>/` (screens + controllers: auth, home, card, qr, payments, classes, bookings, messages, profile).
- **A repository is the only thing that touches `supabase`.** Widgets read providers; providers call repositories; repositories call PostgREST/RPC/functions and map to models. Every repository method runs under `guardFailures()` and surfaces an `AppFailure` (`refused, duplicate, invalid, notFound, offline, unauthenticated, unknown`).
- **One router redirect guard**, driven by `principalProvider`: `signedOut` → `/login`; `member` → `/home`; `signedInNotMember` (valid token, no member claim: member left, org inactive, account unlinked) → a plain "ask the front desk" screen with sign-out. There is no staff branch; a staff-only token is `signedInNotMember`.
- **Claims** the hook stamps (`custom_access_token_hook`): `{ org_id, member_id, role: 'member', branch_ids: [home_branch_id] }`. `isMember` = `role == 'member' && member_id != null`. Malformed claims throw `MalformedClaims` and show the startup failure screen.
- **Writes only through RPCs/functions** (§5). Members have no write policy anywhere; the app must not try.
- **Time:** every date shown is in the org's timezone from `current_member()`, never the phone's. Plain dates (`end_date`) are dates, not instants.
- **Errors are screens, not crashes.** `AsyncValueView` / `FailureView` for reads; snackbars for action failures; an offline failure shows the last cached value with "last updated <time>".
- **Tests mirror `lib/` one-to-one.** Login, claims, formatters, repositories (mocked client), and every controller get tests; the member shell in the staff app has none today — this app does not repeat that.

---

## 4. Authentication — card number + PIN

Decided 2026-11-09. Staff set a PIN for the member from the console (member page or card page) and tell them; the member signs in with **card number or phone, plus PIN**. No email, no invitation, no password, no deep-link.

### 4.1 Identifier and PIN
- **Identifier:** digits only. **1–4 digits** = the printed card number (`NO. 0004`, 1–9999); **7+ digits** = the phone number on file. The server disambiguates by length; anything else is "wrong".
- **The PIN belongs to the member, not the card.** A card is reusable stock and resolves to its *current holder*. Return or replace the card and card-number login stops for the old holder; phone login keeps working. Staff reissuing a card never locks a member out.
- **PIN:** 4–6 digits (final length: open question §10), stored only as a bcrypt hash (pgcrypto) in `member_pins`. Staff set or reset it; the console can generate one and show it once.

### 4.2 Flow
1. Member enters identifier + PIN → app calls the **`member-login`** Edge Function (`verify_jwt` off; org taken from the build's `ORG_SLUG`, never from user input).
2. Function resolves the member (card → `card_stock` → live `member_cards` → member, not archived, not `left`; or phone → `members.phone` in the org), checks the lock, verifies the PIN (`verify_member_pin`, service-role only), counts failures.
3. On success it ensures the member has an auth user (a synthetic, never-mailed account `m-<member_id>@members.invalid`, created with the service role and linked by setting `members.auth_user_id`; **`accepted_at` is left alone** — it requires `invited_at`) and mints a session. The access-token hook then stamps the member claims exactly as for an invited member; **RLS is unchanged.**
4. App stores the refresh token in secure storage and goes to `/home`. The **PIN is not asked again** until the session is revoked or the member signs out.

*Mechanism to prove in a Phase 0 spike:* either return `{access_token, refresh_token}` for `auth.setSession`, or return a magic-link `token_hash` for `verifyOtp`. Also confirm GoTrue accepts the synthetic address and that the email-based `link_member_account` path cannot adopt it. Whatever the spike picks is written back here.

### 4.3 Abuse controls (server-side; the app only displays results)
- 5 consecutive wrong PINs → that member is **locked 15 minutes** (`member_pins.locked_until`); success resets the count. Staff see "locked" and can reset the PIN, which also unlocks.
- Per-IP sliding window in the function (best-effort, per instance) plus a per-org attempt ceiling in Postgres, so a sweep of card numbers cannot be run quietly.
- **Every failure is the same answer** — `{result:'invalid'}` — for unknown card, wrong PIN, unassigned card, archived/left member. The only distinct answers are `locked` (with `retry_after_seconds`) and `rate_limited`. No timing difference between "no such card" and "wrong PIN" (always run a dummy hash compare).
- The PIN travels once over TLS in the POST body; never in a URL, header, log line, or error message. The function never logs it.

### 4.4 After sign-in
- **Member left / org inactive / account unlinked:** the token carries no member claim; show "Your membership is no longer active — please contact the front desk" and offer sign-out.
- **PIN reset by staff while signed in:** existing sessions keep working until they expire or the member signs out; resetting also revokes the member's refresh tokens (backend task) so a lost phone can be cut off.
- **Sign-out** deletes the stored refresh token and calls `revoke_device_token` for this phone (Phase 7).

---

## 5. Data contract

All reads are under member RLS. A `jwt_is_member()` user can `select` (never write): `members` (own), `memberships`, `invoices`, `payments`, `attendance` (own), `orgs` (own), `branches` (home), `classes` (active, home branch), `class_sessions` (home branch), `class_bookings` (own), `notification_messages` (own), `device_tokens` (own), `pt_sessions` (own), member photos (storage, own). Sources: `../logfitness_saas/supabase/migrations/20260905150200_member_scope_rls.sql`, `…160000_classes_schema.sql`, `…170000_device_tokens_and_push.sql`; gate `supabase/tests/member_app.sql`.

### Existing, tested — reuse as is
| Call | Used for |
| --- | --- |
| `current_member()` | Identity, org name/currency/timezone, home branch, `member_code`, status. Readable before claims exist. (Do **not** change its signature — Gym Tross depends on it until Phase 8.) |
| `mint_qr_token(p_member_id?, p_ttl_seconds?)` | Check-in QR. Default 90 s, clamped 10–900. Re-mint ~20 s before expiry, measured from local receipt time; re-check on resume; retry after 10 s on failure. Not single-use — the same-day duplicate check-in guard stops replays. |
| `book_class_session(p_session_id, p_member_id?)` / `cancel_class_booking(p_booking_id, p_reason?)` | Booking; full class → waitlist; cancel promotes the next booking. |
| `register_device_token(...)` / `revoke_device_token(p_token)` | Push registration (Phase 7). |
| `attendance_snapshot(p_member_id)` | Status banner (`active/expiring/expired/frozen/upcoming/none`), plan, days to expiry, dues — the **same function the door and the public balance page use**, so the app never disagrees with them. *Verify it is callable as a member in Phase 0.* |

### New — built in `logfitness_saas` first (`TASKS.md` Phase 0)
| Call | Purpose |
| --- | --- |
| `member_pins` + `verify_member_pin` (service-role only) | Hashed PIN, attempt count, `locked_until`. |
| `set_member_pin(p_member_id, p_pin?)` / `clear_member_pin` | Desk-and-up, branch-scoped, audited. Returns the generated PIN once when none is given. |
| `member-login` Edge Function | §4.2. |
| `my_card()` | `{card_no, card_no_text, assigned_at}` for the member's live card — additive, so `current_member()` is untouched. |
| `request_renewal(p_phone?, p_note?)` | Authenticated member self-call into the existing `renewal_requests` logic (one pending row; repeat within 10 min refused; org hourly cap). Closed automatically when the desk renews. |

### Screens → sources
| Screen | Source |
| --- | --- |
| Home (status chip, days left, plan, due, card no, renewal button/pending) | `attendance_snapshot`, `memberships`, `invoices`, `my_card()`, `request_renewal` |
| QR | `mint_qr_token` |
| Payments / invoices | `invoices`, `payments` |
| Classes / bookings | `class_sessions` (+ `classes`), `class_bookings`, `book_class_session`, `cancel_class_booking` |
| Messages | `notification_messages` |
| Profile | `current_member()`, `my_card()` |

---

## 6. Conventions

- **Money** is integer paisa in `int`; one formatter at the render boundary (port of `../logfitness_saas/lib/format.ts`; same as the staff app's `Money`).
- **l10n:** `lib/l10n/app_en.arb` and `app_ne.arb`, keys added to both in the same change; a test fails if the key sets differ. Nepali copy is reviewed by the gym before release (§10). Device language decides, with an in-app override.
- **Theme:** Material 3, light + dark, brand tokens taken from `../logfitness_web` (LOG's two-colour brand; no third colour for status — use weight/outline). Pinned in Phase 1.
- **Config:** `--dart-define-from-file=env/local.json` with `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `ORG_SLUG`. `env/local.example.json` committed; `env/local.json` gitignored; `assertConfigured()` at start-up shows the startup failure screen instead of a frozen logo. No flavors.
- **Generated code is committed;** CI fails if `build_runner` output differs.
- **Accessibility:** large tap targets, text scales with the OS setting, status never conveyed by colour alone, PIN field is `obscureText`, numeric keyboard, no autofill, screenshots blocked on the PIN screen.
- **Commits:** logical, small; migrations never in this repo.

---

## 7. Delivery phases

0. **Backend prerequisites** (`→ logfitness_saas`): PINs, `member-login`, `my_card()`, `request_renewal()`, console PIN controls, spike of the session mechanism.
1. **Foundation:** project, config, theme, l10n scaffold, claims/session/router guard, generated models, formatters, CI.
2. **Auth:** PIN login, lockout/error states, session restore, "not a member" screen, sign-out.
3. **Home & profile:** status, days left, plan, card number, dues, renewal request.
4. **QR check-in.**
5. **Payments & invoices.**
6. **Classes, bookings, messages.**
7. **Push** (Firebase project, tokens, permissions, device verification).
8. **Release + Gym Tross cleanup:** store listing, privacy manifest, signing, TestFlight/Play internal, then remove the member shell from `../logfitness_flutter`.

Order matters: Phase 0 gates Phase 2; Phases 4–6 are ports and can run in any order once Phase 1 is done; Phase 8's Gym Tross removal happens only after this app is in members' hands.

---

## 8. Out of scope for v1

Any staff feature; online payment, card-on-file, QR/UPI payment; self-service plan change, freeze, or cancel; workout programs, exercise library, body tracking; social features, leaderboards, referrals; marketing or CRM; multi-gym selection or white-label builds; offline write queue; biometric unlock; Apple/Google Wallet pass for the card; phone-OTP login (the PIN design leaves room to add it later).

---

## 9. Current state (2026-11-09)

- This repo is **empty** apart from these docs (one prior commit, empty `CLAUDE.md`). No Flutter project yet.
- Backend already in place for members: invite/link auth, `current_member()`, member RLS, `mint_qr_token`, class booking RPCs, `device_tokens` + `push-fanout` (FCM send path **unverified**).
- Backend in place since 2026-11-09 and relevant here: printed card numbers (`card_stock`, `NO. 0004`), `renewal_requests`, the public `public-balance` function and `lordofgyms.com/balance`, `/cards`. LOG has cards 0001–0070 numbered; chips are linked as members are given cards.
- **Not yet built:** PIN storage, `member-login`, `my_card()`, `request_renewal()`, console PIN controls — all Phase 0.
- Gym Tross still has the member shell and the email-invite flow (`invite_member`, `link_member_account`); both are retired in Phase 8.

---

## 10. Open questions

- **Final bundle id and store name** (`com.lordofgyms.member` / "LOG Fitness" are placeholders); Apple/Google accounts and team ids for the new app.
- **PIN length** — fixed 4, or 4–6? A longer PIN resists guessing; a shorter one suits gym-floor use.
- **Can the member change their own PIN in the app?** Reduces desk load but needs the current PIN and another RPC. Not in v1 unless decided.
- **Firebase project** and who owns it; the `FCM_SERVICE_ACCOUNT_JSON` secret; notification categories members can mute.
- **Nepali copy review** — who at the gym signs off the strings.
- **Biometric unlock** (Face/Touch ID after first PIN login) — after v1?
- **Add-to-wallet pass** for the card/QR — after v1?
- **Realtime vs polling** for booking capacity and messages (the staff app polls).
- **What to do with `invite_member` / email accounts** already created for members — migrate to PIN, or leave both paths?

---

## 11. Changes after the first device run (2026-11-09)

- **Tabs:** Home, Attendance, Check-in, Payments, Profile (`enabledTabs` in `lib/app/features.dart`). Classes/Bookings are behind `kClassesEnabled` (off). Messages is reached from Home.
- **Renewal:** one tap, no sheet. `request_renewal(p_phone)` with the profile phone; `my_renewal_request()` returns the pending request so the state persists. Staff see it in the console: sidebar badge on Members, dashboard card, live pop-up (Supabase realtime on `renewal_requests`), the `/members/requests` page and the member-profile banner.
- **Attendance calendar:** `my_attendance_calendar(p_year, p_month)` → per-day `present | absent | off | holiday | none` computed in Postgres in the org timezone. `absent` = a day inside a non-cancelled membership window, not today/future, not a weekly-off day or holiday (console Settings → Gym schedule: `orgs.settings.weekly_off`, `org_holidays`), not currently frozen, with no visit.
- **Door check-in:** the door's OLED shows a rotating QR (`LG1.<qr_id>.<code>`, code = 8-digit HMAC of the device secret over 30 s windows, server accepts ±1 window). The app scans it and calls `member_door_check_in(p_payload)`; on success the server records attendance (`method='qr'`) and queues an unlock that the door fetches from `rfid-poll` within 20 s. Only inside branch opening hours; per-member bad-code throttle. A live photo of the screen can still be relayed within ~60 s (accepted trade-off). Firmware lives in `../logfitness_saas/firmware/rfid-check-in` (v1.4.0, not yet run on hardware).
- **Security note found on the way:** `set_org_setting` let any signed-in member change gym settings (null-unsafe owner check); fixed in `logfitness_saas` migration `20261109130100`.
