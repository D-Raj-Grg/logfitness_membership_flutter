// Shown while the session is restored / claims are resolved (principal is
// loading). Owned by the Auth agent for polish; the router imports
// `SplashScreen` by this name.
import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).appName.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
