# TASKS — Lord of Gyms Member

Check this before starting work. Mark tasks `[x]` the moment they are done, not at the end of the session. Add newly discovered tasks under their phase or under **Discovered**. Phase 0 items live in the `logfitness_saas` repo (marked **→ logfitness_saas**) and are mirrored in `../logfitness_saas/TASKS.md` → Discovered; tick them in both places.

Phase order matters: **Phase 0 gates Phase 2** (login needs the backend). Phases 4–6 are ports and can run in any order once Phase 1 is done. Do not skip ahead without an explicit instruction.

---

## Phase 0 — Backend prerequisites (→ logfitness_saas)

Build and test these in `../logfitness_saas` (migrations through Supabase MCP, SQL gates in `supabase/tests/`, every new function revoked from `public, anon` with explicit grants, cross-tenant negative tests). This app builds against them once they land.

- [ ] **Spike: session mechanism.** Prove `member-login` can create a synthetic auth user (`m-<member_id>@members.invalid`) and mint a session the app can use — either return `{access_token, refresh_token}` for `auth.setSession`, or a magic-link `token_hash` for `verifyOtp`. Confirm GoTrue accepts the address, that `link_member_account` (email-based) can never adopt it, that `custom_access_token_hook` stamps `{org_id, member_id, role:'member', branch_ids}` for it, and that `members_accept_requires_invite` is respected (`accepted_at` stays null). Write the result into `PLANNING.md` §4.2.
- [ ] `member_pins` table: `member_id` (pk, composite fk to `members`), `pin_hash` (bcrypt via pgcrypto), `failed_attempts`, `locked_until`, `set_by`, `set_at`. RLS on; no client policies; no client write privilege.
- [ ] `verify_member_pin(p_member_id, p_pin)` — **service_role only**; constant-ish time (dummy hash when no PIN row); increments `failed_attempts`; 5 failures → `locked_until = now() + 15 min`; success resets. Returns a jsonb result, never raises for a business outcome.
- [ ] `set_member_pin(p_member_id, p_pin default null)` / `clear_member_pin(p_member_id)` — desk and up, branch-scoped like the rest of the desk, audited (never writing the PIN or hash to `audit_log`); with no `p_pin`, generates one and returns it **once**; resetting clears the lock and revokes the member's refresh tokens.
- [ ] `member-login` Edge Function (`verify_jwt` off): input `{identifier, pin}` (+ org from build config, validated against `orgs.slug`); 1–4 digits → card number path, 7+ digits → phone path (normalise with the existing msisdn helper); resolves card → `card_stock` → live `member_cards` → member (not archived, not `left`); one generic `{result:'invalid'}` for every failure; distinct `locked` (+ `retry_after_seconds`) and `rate_limited`; per-IP window using the **last** `x-forwarded-for` hop; per-org attempt ceiling in Postgres; never logs the PIN; CORS not required (native app) — no `*`.
- [ ] SQL gate `supabase/tests/member_pin_login.sql`: wrong/right PIN, lockout and reset, unassigned card, archived/left member, card reissued to someone else, phone vs card ambiguity (3-digit vs 7-digit), cross-org isolation, no function callable by `anon`/`authenticated` except `set_member_pin`/`clear_member_pin` (desk+).
- [ ] Console: PIN controls on `/members/[id]` (Set / Reset / Clear, shows "locked until …", shows a generated PIN once) and on the `/cards` row of an assigned card.
- [ ] `my_card()` RPC — `{card_no, card_no_text, assigned_at}` for the member's live card, member-callable; **additive**, `current_member()` is left unchanged (Gym Tross depends on it until Phase 8).
- [ ] `request_renewal(p_phone default null, p_note default null)` — authenticated-member self-call reusing the `renewal_requests` rules (one pending per member; repeat within 10 min refused; org hourly cap; first phone/note stand; card stock id attached); returns a jsonb result like `public_renewal_request`; closed by the desk's renewal as today.
- [ ] Verify `attendance_snapshot(member_id)` is callable by a `jwt_is_member()` token for their own id only (RLS), and returns the banner/days/dues the home screen needs. If not, add a member-safe wrapper.
- [ ] Revoke-sessions helper used by PIN reset (service-role): sign out all of a member's auth sessions.
- [ ] Push: create the Firebase project for this bundle id, set `FCM_SERVICE_ACCOUNT_JSON` on Supabase, verify the `push-fanout` send path end to end to a real device (**unverified today**).
- [ ] Regenerate `lib/types/database.ts` and tell this repo to regenerate models.

---

## Phase 1 — Foundation

- [x] `flutter create` in this repo: org `com.lordofgyms`, project `logfitness_membership_flutter`, iOS + Android only; display name "LOG Fitness".
- [x] `.gitignore`: `env/local.json`, `*.jks`, `android/key.properties`, `google-services.json`, `GoogleService-Info.plist`, build output. Commit `env/local.example.json`.
- [x] Pin SDK (`sdk: ^3.10.7`, Flutter `>=3.38.0`); pubspec per `PLANNING.md` §2 (copy the staff app's `path_provider_foundation: 2.4.1` override and Android `compileSdk` 36 pin).
- [x] Lints: `flutter_lints`, `riverpod_lint`, `custom_lint`; analysis options match the staff app.
- [x] Config: `--dart-define-from-file` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `ORG_SLUG`); `supabase_config.dart` with `assertConfigured()`; `StartupFailureApp` on bad config.
- [x] `supabase_bootstrap` with `SecureSessionStorage` (refresh token in `flutter_secure_storage`).
- [x] `ProviderScope`, `sessionProvider`, `claimsProvider` (`AppClaims`: `org_id`, `member_id`, `role`, `branch_ids`; `isMember`; `MalformedClaims`), `principalProvider` (`signedOut | member | signedInNotMember`).
- [x] Router with the single redirect guard (`/splash`, `/login`, `/home`, `/not-member`).
- [x] Generated models + Dart enums matching Postgres (`member_status`, `membership_status`, `invoice_status`, `payment_method`, class/booking enums, notification enums); `build_runner` wired.
- [x] `repository_guard` (`guardFailures`, `rpcParams`), `AppFailure` + `FailureKind`, `AsyncValueView` / `FailureView` / failure snackbar — ported from the staff app.
- [x] Formatters: `Money` (paisa → text, once), dates in the org timezone, plain dates, relative time; ported with their tests.
- [x] Theme: Material 3 light + dark from the LOG brand tokens in `../logfitness_web` (record the chosen seed/tokens in `PLANNING.md` §6); theme mode in `shared_preferences`.
- [x] l10n scaffold: `l10n.yaml`, `app_en.arb`, `app_ne.arb`, language override; test that both key sets are identical.
- [x] Shell: a bottom-nav `MemberShell` (Home, Classes, Check-in, Payments, Profile) with empty screens; Messages reachable from Home/Profile.
- [x] CI `.github/workflows/ci.yaml`: pub get, `build_runner build`, generated-files diff check, `flutter analyze`, `dart run custom_lint`, `flutter test`.
- [x] `README.md`: run instructions (`flutter run --dart-define-from-file=env/local.json`).

---

## Phase 2 — Auth (needs Phase 0)

- [x] `MemberAuthRepository`: `login(identifier, pin)` → `member-login`; maps `ok / invalid / locked / rate_limited` to a sealed result; sets the session; **does not retain the PIN**.
- [x] Login screen: one "Card number or phone" field (numeric), one PIN field (obscured, numeric, no autofill, screenshots blocked), submit, loading and error states; one generic failure message; `locked` shows "try again in N minutes"; `rate_limited` shows a wait message; "Forgot PIN? Ask the front desk" help text with the gym's phone number.
- [ ] Session restore on cold start; handle an expired/revoked refresh token by returning to login with a neutral message.
- [x] `/not-member` screen (member left / org inactive / unlinked): contact copy, call button, sign-out.
- [ ] Sign-out (secure storage cleared; push token revoked once Phase 7 lands).
- [ ] Tests: result mapping, redirect guard for each principal, PIN never present in provider state or logs, lockout copy.

---

## Phase 3 — Home & profile

- [x] Home: status chip (`active / expiring / expired / frozen / upcoming / none` — weight/outline, never colour alone), **days left** as the headline (status first, then days: expired shows "Expired N days ago", frozen shows "Frozen", upcoming shows "Starts soon"), plan name, end date, amount due (sum of non-void `due_paisa`), **card number** (`NO. 0004`).
- [x] **Request renewal** button → `request_renewal`; pending state ("Requested <time> — the front desk will call you"); `too_soon` and org-cap copy; optional phone/note sheet.
- [x] Pull-to-refresh; last-known value with "last updated" when offline.
- [x] Profile: name, member code, card number, home branch, phone, language switch, theme, app version, sign-out. Read-only otherwise.
- [x] Tests: headline logic per status (including expired-with-sessions-used and frozen), renewal pending/too_soon, formatter edge cases.

---

## Phase 4 — QR check-in

- [x] Port `qr_token_repository` + `member_qr_screen` from the staff app: mint, render with `qr_flutter`, re-mint 20 s before expiry (clock from local receipt), re-check on app resume, retry after 10 s on failure, brightness boost while shown.
- [x] Not-eligible states (expired / dues) show the gym's reason text rather than a QR the door will refuse.
- [x] Tests: refresh scheduling, resume behaviour, failure retry.

---

## Phase 5 — Payments & invoices

- [x] Port `member_payments_screen`: invoices (number, total, paid, due, status) and payments (date, amount, method, refunds as negative with reason); read-only.
- [x] Invoice detail view; receipt/invoice sharing is **out** for v1 (staff print them).
- [x] Tests: money formatting, refund display, empty states.

---

## Phase 6 — Classes, bookings, messages

- [x] Port `member_classes_screen` + `class_board_notifier`: upcoming sessions at the home branch, capacity, book / join waitlist / cancel with optimistic UI and rollback on refusal; use the RPC's refusal text. (Day selector for the next 7 days in the org timezone; poll every 30 s while the tab is visible and the app is foregrounded.)
- [x] Port `member_bookings_screen` (upcoming / past, cancel with confirm). Waitlist *position* is not shown: other members' bookings are invisible under RLS, so only "on the waitlist" is known. Trainer name is not shown either: `staff` is not readable by members.
- [x] Port `member_messages_screen` (`notification_messages`, newest first, explicit `ascending: false`); mark-read is client-local only (no write policy, in-memory per launch). Only `status = 'sent'` rows are listed.
- [x] Decide polling vs Realtime for capacity and messages (see `PLANNING.md` §10) and record it. **Decision: polling.** Classes board re-reads every 30 s while the tab is visible and the app is resumed (stops when hidden/backgrounded, refreshes on return); booking RPC re-checks capacity under a row lock, so a stale count is only cosmetic. Messages re-read on open and on pull-to-refresh; push (Phase 7) is the live channel.
- [x] Tests: booking states (booked / waitlisted / full / cancelled), optimistic rollback, message ordering, day grouping, capacity label.
- [ ] Verify live with a real member: book, fill-then-waitlist, cancel inside the cancellation window (RPC refusal text), cancel promotes the waitlist, messages list against real `notification_messages` rows.

---

## Phase 7 — Push

- [ ] Phase 0 push items done (Firebase project, secret, `push-fanout` verified to a device).
- [ ] `firebase_core` + `firebase_messaging`; `GoogleService-Info.plist` / `google-services.json` (gitignored).
- [ ] iOS: Push Notifications capability, `UIBackgroundModes: remote-notification`, APNs key uploaded to Firebase. Android: `POST_NOTIFICATIONS` runtime permission (API 33+), notification channel.
- [ ] Permission prompt at a sensible moment (after first successful login, with a one-line reason in both languages), never at launch.
- [ ] `register_device_token` after login and on token refresh; `revoke_device_token` on sign-out; tap-through routes to Messages / the relevant booking.
- [ ] **Verified on a real iPhone and a real Android phone** before this phase is ticked.

---

## Phase 8 — Release + Gym Tross cleanup

- [ ] Final bundle id / applicationId, store name, icon (hand-tuned, no generator), splash, Apple and Google app records.
- [ ] `docs/RELEASE.md` — adapt the staff app's workflow (versioning rules, `scripts/bump_version.sh`, TestFlight script with the "supabase.co baked into the IPA" guard, Android upload keystore outside the repo, Play internal track). Always check the stores for the real highest build number.
- [ ] iOS: `ITSAppUsesNonExemptEncryption=false`; `PrivacyInfo.xcprivacy` matching the App Store privacy answers (collects: name, phone, membership/payment history, push token); account-deletion / data-request path described in the listing (contact the gym).
- [ ] Android: Play App Signing, data-safety form, first upload manual.
- [ ] `docs/STORE_LISTING.md` (EN + NE): description, short description, screenshot shot list; demo data only, never real members.
- [ ] Privacy policy and support links.
- [ ] CI release workflow (`workflow_dispatch`) with its secrets; crash reporting decision.
- [ ] Pilot: install on 5–10 LOG members' phones via TestFlight / Play internal; fix what they hit.
- [ ] **Gym Tross cleanup** (in `../logfitness_flutter`, after members have this app): delete `lib/features/member/**` and its data code that nothing else uses; a member principal now lands on a "Please use the Lord of Gyms app" screen with store links; version bump (minor, per its `docs/RELEASE.md`); update its `CLAUDE.md`/`PLANNING.md`/`STORE_LISTING.md` ("For members" bullets go); tests and CI green.
- [ ] Retire the email-invite path (`invite_member`, `link_member_account`, console "Invite to app") or keep it deliberately — decide and record (→ logfitness_saas).

---

## Discovered

<!-- Format: - [ ] **YYYY-MM-DD** What was found and what to do about it -->

- [ ] **2026-11-09** `PLANNING.md` §3/§5 says the hook stamps `role: 'member'`. It does not: the deployed `custom_access_token_hook` (migration `20260905150300`) leaves `role` as PostgREST's `authenticated` and the principal is the presence of `member_id` (staff carry `staff_role`). `AppClaims.isMember` is `member_id != null && staff_role == null`. Correct the wording in PLANNING.
- [ ] **2026-11-09** Theme tokens chosen in Phase 1 (record in `PLANNING.md` §6): Tar Road `#17181D`, Elegant Grey `#8B9096`, paper `#F4F5F6`, grey-ink `#565B62` (Elegant Grey darkened for small text on white); error red `#B3261E`/`#FFB4AB` is the only non-brand hue. No bundled font yet (web uses Anton + Inter).
- [ ] **2026-11-09** Theme mode defaults to `system` here (staff app defaults to light).
- [ ] **2026-11-09** `FailureView` headings are localised; the sentence beneath (`AppFailure.message`) is English from `mapError` or the database. Localise the mapper's own sentences before release.
- [ ] **2026-11-09** The staff app's member shell has no tests. Everything ported from it gets tests in this repo (Phases 3–6); do not copy untested code across without them.
- [ ] **2026-11-09** The staff app's push is declared but unwired and the FCM send path is unverified upstream. Treat push as new work with a verification gate, not a port.
- [ ] **2026-11-09** Files copied from the staff app can drift. When a bug is fixed in a copied file in either repo, add a line here (or in `../logfitness_flutter/TASKS.md`) naming the counterpart.

- [ ] **2026-11-09** Login screen blocks screenshots on Android only (`FLAG_SECURE` via `MainActivity` channel `com.lordofgyms.member/screen_security`). iOS has no per-screen equivalent; the PIN field is `obscureText` and a snapshot hides typed digits. Revisit before release (secure-text-field overlay or `UIScreen.isCaptured` blur).
- [ ] **2026-11-09** `attendance_snapshot` returns no dates (`membership_id, membership_status, plan_name, days_to_expiry, sessions_remaining, due_paisa, banner`), so `AttendanceRepository.fetchSnapshot` also reads `start_date,end_date` from the member's own `memberships` row by id (RLS). A member-safe `my_snapshot()` wrapper that includes the dates would remove the second round trip. Unverified live: that `attendance_snapshot` is callable by a member token for their own id (Phase 0 item).
- [ ] **2026-11-09** Phase 2 leftovers: session restore on an expired/revoked refresh token should return to login with a neutral message (not built); sign-out does not yet revoke the push token (Phase 7); redirect-guard tests per principal already exist in `test/app/router_test.dart`; the login "PIN never in provider state" property is covered structurally (local controller) not by a log-capture test.
- [ ] **2026-11-09** Renewal "pending" is in-memory only (resets on app restart; the server's `too_soon` answer re-establishes it). Showing a persisted pending state needs a member-readable source for `renewal_requests` (none today).
- [ ] **2026-11-09** Login help text has no gym phone number (it is not known before sign-in). Add a build-time `SUPPORT_PHONE` define or org setting if the gym wants a tap-to-call.

---

## Open questions

See `PLANNING.md` §10 for the full list. The ones that block work:

- [ ] Final bundle id / store name and the Apple/Google accounts that own them (blocks Phase 1 `flutter create` org if it changes, and all of Phase 8).
- [ ] PIN length (blocks Phase 0 `set_member_pin` validation).
- [ ] Who signs off the Nepali strings, and by when (blocks Phase 8).
- [ ] Does the member change their own PIN in v1? (If yes, add `change_own_pin` to Phase 0 and a screen to Phase 3.)
