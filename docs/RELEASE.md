# Releasing LOG Fitness to TestFlight (iOS)

Bundle id `com.lordofgyms.member`, team `456X78R628` (same Apple team and API key as Gym Tross). Version lives in `pubspec.yaml` (`1.0.0+1`); the App Store listing uses two-part versions (1.0, 1.1).

## One-time (Apple side)
1. The team's Account Holder accepts the latest **Program License Agreement** (developer.apple.com/account). Until then Apple's API and Xcode signing fail with `PLA_NOT_ACCEPTED`.
2. In App Store Connect create the app: iOS, name **LOG Fitness**, bundle id `com.lordofgyms.member` (register it at developer.apple.com -> Identifiers if missing), any SKU. Apple's API cannot create app records.
3. Optional: create an Internal Testing group and add testers.

## Build and upload
```
flutter build ipa --release --dart-define-from-file=env/local.json --export-options-plist=ios/ExportOptions.plist
xcrun altool --validate-app --type ios -f build/ios/ipa/*.ipa --apiKey 9F7ZP42SW7 --apiIssuer 0fcf1157-470a-4448-a1fe-3e450ad56ccb
xcrun altool --upload-app  --type ios -f build/ios/ipa/*.ipa --apiKey 9F7ZP42SW7 --apiIssuer 0fcf1157-470a-4448-a1fe-3e450ad56ccb
```
- **Never omit `--dart-define-from-file=env/local.json`**: without it the app has no Supabase URL and freezes on launch. Check the IPA: extract `Payload/Runner.app/Frameworks/App.framework/App` and `strings -a` it; `supabase.co` must appear.
- Xcode bumps the build number on export; read `CFBundleVersion` from the exported IPA (`Payload/Runner.app/Info.plist`), not from the log. Bump `pubspec.yaml` above the highest build already in App Store Connect.
- The API key is `~/.appstoreconnect/private_keys/AuthKey_9F7ZP42SW7.p8`; `python3 ~/.appstoreconnect/asc.py GET|POST|PATCH <path>` drives the API (paths without `/v1`).
- A processed build reaches testers only after it is added to a beta group.

## Before the first external/App Store submission
Privacy answers (collects name, phone, membership/payment history, push token later), privacy policy URL, screenshots (demo data only), Nepali listing copy reviewed by the gym, account-deletion path (contact the gym).
