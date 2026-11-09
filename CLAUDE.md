# Lord of Gyms Member — session rules

This is the **members' app** (store name "LOG Fitness"). It is a separate binary from `../logfitness_flutter` ("Gym Tross"), which is the staff and management app. Members never use Gym Tross; staff never use this.

## Start of every conversation

1. **Read `PLANNING.md` first.** It holds the architecture, stack, auth model, data contract, and conventions. Do not propose or write code before reading it.
2. **Read `TASKS.md` before starting work.** Pick up the current phase. Do not skip ahead to a later phase without an explicit instruction.
3. **Mark tasks `[x]` in `TASKS.md` the moment they are complete** — not at the end of the session.
4. **Add newly discovered tasks to `TASKS.md`** as you find them, under the phase they belong to or under **Discovered**.

Product context lives in `../logfitness_saas/docs/PRD.md`. The backend contract lives in `../logfitness_saas/PLANNING.md` (see "Printed card numbers are stock" for card numbers, the public balance page, and renewal requests). The staff app `../logfitness_flutter` is the style and code reference — its member shell (`lib/features/member/**`) is what this app is ported from. Read them when scope, schema, or priority is in question.

## Hard rules

- **The database is not ours.** Schema changes, RPCs, and Edge Functions belong in `logfitness_saas`, applied through Supabase MCP. This repo never writes a migration. If the app needs a column, a policy, an RPC, or a function, add the task to `../logfitness_saas/TASKS.md` first and build against it once it lands. Phase 0 of `TASKS.md` is exactly that list.
- **RLS is the tenant boundary.** Never hand-filter by `org_id` or `member_id` in Dart as a security measure. A query that returns the right rows only because of a client-side filter is a bug — fix the policy, not the query. A member sees one person's data; the database enforces it.
- **The PIN is a secret the app never keeps.** Never store it, log it, put it in a crash report, echo it in an error, or hold it in a provider after the login call returns. It is sent once, over TLS, to the `member-login` function. Disable autofill history and screenshots on the PIN field.
- **One generic login failure.** Wrong card number, wrong PIN, locked, unknown member — the screen says the same thing ("card number or PIN is wrong") unless the function returns the explicit `locked` result. Never let the UI reveal whether a card number exists.
- **Money is integer paisa in `int`.** Convert to a decimal exactly once, in the formatter at the render boundary — never in queries, totals, or business logic. Dart mirror of `../logfitness_saas/lib/format.ts`.
- **Writes go through existing RPCs, never table calls.** Members have no write policy on any table. Booking is `book_class_session` / `cancel_class_booking`; QR is `mint_qr_token`; a renewal request is `request_renewal`; push tokens are `register_device_token` / `revoke_device_token`. A `supabase.from(...).insert/update/delete` in this app is a bug.
- **Never set `members.status`.** It is trigger-derived in the database.
- **Financial history is append-only and read-only here.** The app shows invoices and payments; it never edits them. Renewal is a *request* the front desk fulfils — there is no payment in the app.
- **Models are generated, not hand-written.** `freezed` + `json_serializable` off the Supabase schema, regenerated after any migration lands in the SaaS repo. Dart enum values must match the Postgres enums exactly.
- **Run `build_runner` after touching any annotated file.** Riverpod, freezed, and go_router codegen share it; a stale `.g.dart` fails in confusing ways.
- **Repositories are the only thing that touches `supabase`.** A widget that builds a PostgREST query is a review failure.
- **Every user-facing string goes through l10n, English and Nepali together.** No literal strings in widgets. A new key lands in both `.arb` files in the same change.
- **Always pass `ascending:` to `.order()`.** postgrest-dart defaults to descending.
- **Flutter 3.38 / Dart 3.10 differ from training data.** Verify the current API before writing. Heed deprecation notices from `flutter analyze`.
- **Role gates the shell, RLS gates the data.** Client-side checks are UX only. Never treat a hidden button as an access control.

## Scope discipline

This app is for **members of one gym** (LOG; the org is fixed at build time). It shows their membership, card, dues, payment history, QR check-in, classes and bookings, and messages, and lets them *ask* to renew.

v1 excludes: any staff or management feature, online payment or card-on-file, self-service plan change or freeze, workout programs, body tracking, social features, marketing, multi-gym selection (a white-label build for another gym is a later decision, not a flag). **Offline-first is deferred, not solved** — cache last-known reads and show them with a "last updated" note; no local write queue (booking and renewal requests need the server's answer). Do not build these without an explicit scope decision.

**Push is not done until it is verified on a device.** `firebase_messaging` needs its own Firebase project for this bundle id and the `FCM_SERVICE_ACCOUNT_JSON` secret on the Supabase side; until a real notification arrives on a real phone, the push tasks stay unchecked.

**Gym Tross keeps its member shell until this app ships.** Removing it is the last phase (`TASKS.md` Phase 8), done in `../logfitness_flutter`, not here.
