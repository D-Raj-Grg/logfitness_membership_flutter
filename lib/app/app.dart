import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/locale_controller.dart';
import 'package:logfitness_membership_flutter/app/router.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/app/theme_mode_controller.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Root widget: the two Material 3 themes, the localisation delegates and the
/// [goRouterProvider] in a single [MaterialApp.router].
class LogMemberApp extends ConsumerWidget {
  const LogMemberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ref.watch(themeModeProvider),
      // `null` = follow the device; the resolution below falls back to English
      // for any language we do not ship.
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
