import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/app.dart';
import 'package:logfitness_membership_flutter/app/locale_controller.dart';
import 'package:logfitness_membership_flutter/app/startup_failure_app.dart';
import 'package:logfitness_membership_flutter/app/theme_mode_controller.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
    await initSupabase();

    // Read the stored choices before the first frame so nobody sees a flash
    // of the wrong theme or language.
    final ThemeMode themeMode = await loadThemeMode();
    final Locale? locale = await loadLocaleOverride();

    runApp(
      ProviderScope(
        overrides: [
          themeModeStartupProvider.overrideWithValue(themeMode),
          localeStartupProvider.overrideWithValue(locale),
        ],
        child: const LogMemberApp(),
      ),
    );
  } catch (error) {
    // Without this a throw here leaves the launch screen up forever.
    runApp(StartupFailureApp(error: error));
  }
}
