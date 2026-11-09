// PLACEHOLDER from the foundation. The owning feature agent REPLACES this file
// wholesale; keep the class name `NotMemberScreen` (the router imports it by that name).
import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/features/common/placeholder_screen.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

class NotMemberScreen extends StatelessWidget {
  const NotMemberScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: AppLocalizations.of(context).appName);
}
