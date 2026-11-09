// The in-app language override.
//
// `null` means "follow the phone" (device locale, resolved against
// `AppLocalizations.supportedLocales`: en, ne; anything else falls back to
// English). A member can pick English or Nepali on the profile screen and it
// sticks. Stored in `shared_preferences` (a preference, not a credential),
// read before the first frame in `main()` exactly like the theme mode.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'locale_override';

/// Language codes the app ships. Keep in step with `l10n.yaml` / the arbs.
const List<String> kSupportedLanguageCodes = <String>['en', 'ne'];

/// The override read from disk before the first frame; `null` = follow device.
final localeStartupProvider = Provider<Locale?>((ref) => null);

/// Reads the stored override. Unreadable store or unknown code means "follow
/// the device" -- never a reason to fail to start.
Future<Locale?> loadLocaleOverride() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return localeFromCode(prefs.getString(_prefsKey));
  } catch (_) {
    return null;
  }
}

Locale? localeFromCode(String? code) =>
    code != null && kSupportedLanguageCodes.contains(code) ? Locale(code) : null;

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => ref.watch(localeStartupProvider);

  /// Pass `null` to go back to following the device.
  Future<void> set(Locale? locale) async {
    state = locale;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setString(_prefsKey, locale.languageCode);
      }
    } catch (_) {
      // A failed write costs the preference next launch, not the switch now.
    }
  }
}

/// Watched by `MaterialApp.router(locale: ...)`.
final localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
