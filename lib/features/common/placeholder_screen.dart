import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// What every not-yet-built screen shows. Feature agents REPLACE their
/// screen file wholesale and stop using this; it is foundation scaffolding,
/// not a design element.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Brand.gutter),
          child: Text(
            AppLocalizations.of(context).comingSoon,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
