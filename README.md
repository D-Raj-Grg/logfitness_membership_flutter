# LOG Fitness (members' app)

Flutter app for members of Lord of Gyms (LOG): membership status, card, dues, QR
check-in, classes, messages. Separate binary from the staff app
(`../logfitness_flutter`, "Gym Tross"). Read `CLAUDE.md`, `PLANNING.md` and
`TASKS.md` before changing anything.

Flutter 3.38.7 / Dart 3.10.7. Bundle id `com.lordofgyms.member`, iOS + Android, portrait only.

## Run

```sh
cp env/local.example.json env/local.json   # then fill in the values (gitignored)
flutter pub get
flutter run --dart-define-from-file=env/local.json
```

`env/local.json` needs `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `ORG_SLUG`
(LOG is `lord-of-gyms-fitness-b1b886`). A build without them shows a plain
"couldn't start" screen naming what is missing.

## Codegen (freezed / json_serializable / riverpod)

Generated files are committed; CI fails if they are stale.

```sh
dart run build_runner build -d
```

## Strings (l10n): fragments, not the shared arbs

Every user-facing string is English + Nepali. To avoid merge conflicts between
people working in parallel, **do not edit `lib/l10n/app_en.arb` / `app_ne.arb`**
(they hold only shared keys: app name, tabs, retry, failure headings...).
Instead each feature owns two flat JSON files:

```
lib/l10n/fragments/<feature>_en.json
lib/l10n/fragments/<feature>_ne.json
```

```json
{
  "homeDaysLeft": "{count, plural, =1{1 day left} other{{count} days left}}",
  "@homeDaysLeft": { "placeholders": { "count": { "type": "int" } } }
}
```

Keys are camelCase and must be unique across the whole app (prefix with the
feature: `homeX`, `qrX`, ...). Both languages must define the same keys. Then:

```sh
dart run tool/merge_arb.dart && flutter gen-l10n
```

`merge_arb` folds all fragments into the two arbs (sorted; a duplicate key is an
error), `gen-l10n` regenerates `lib/l10n/app_localizations*.dart`. Commit the
fragments, the merged arbs and the generated Dart. Use strings with
`AppLocalizations.of(context).someKey`
(`import 'package:logfitness_membership_flutter/l10n/app_localizations.dart'`).

## Brand assets (icon, splash)

`flutter test tool/gen_icons_test.dart` regenerates the iOS/Android icons and
splash images from the vector `LogMark`. See `docs/BRANDING.md`.

## Quality gate

```sh
flutter pub get && dart run build_runner build -d \
  && dart run tool/merge_arb.dart && flutter gen-l10n \
  && flutter analyze && dart run custom_lint && flutter test
```

`test/l10n_parity_test.dart` fails if the English and Nepali key sets differ.

## Where things live

`lib/app` (app, router, theme, brand, startup failure) · `lib/supabase` (config,
bootstrap, claims, principal) · `lib/data/<module>` (repositories + models; the
only code that touches `supabase`) · `lib/domain` (enums, errors, formatters) ·
`lib/features/<module>` (screens + controllers) · `lib/features/common`
(`LogCard`, `StatusPill`, `SectionHeader`, `SkeletonBox`, `AnimatedCount`,
`AsyncValueView`, `FailureView`, snackbars).

## Merge conflicts in derived l10n files

`lib/l10n/app_en.arb`, `app_ne.arb`, `app_localizations*.dart` and
`lib/l10n/fragments/.merged_*.manifest` are all derived from the fragments.
If git reports a conflict in any of them after a merge/rebase, take either
side and re-run `dart run tool/merge_arb.dart && flutter gen-l10n`. Never
hand-resolve them. Only a conflict inside a `fragments/<feature>_*.json` is a
real conflict.
