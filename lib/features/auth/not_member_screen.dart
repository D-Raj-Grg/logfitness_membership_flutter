import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/features/auth/log_monogram.dart';
import 'package:logfitness_membership_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key notMemberSignOutKey = Key('not-member-sign-out');

/// A valid token without a member claim: the member left, the org is inactive
/// or the account is unlinked. Calm copy, one way out.
class NotMemberScreen extends ConsumerStatefulWidget {
  const NotMemberScreen({super.key});

  @override
  ConsumerState<NotMemberScreen> createState() => _NotMemberScreenState();
}

class _NotMemberScreenState extends ConsumerState<NotMemberScreen> {
  bool _busy = false;

  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await ref.read(memberAuthRepositoryProvider).signOut();
    } catch (e, st) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnackBar(context, e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Brand.gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const LogMonogram(size: 72),
                  const SizedBox(height: Brand.spaceLg),
                  Text(
                    l10n.authNotMemberTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: Brand.spaceSm),
                  Text(
                    l10n.authNotMemberBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Brand.spaceXl),
                  SizedBox(
                    width: double.infinity,
                    height: Brand.buttonHeight,
                    child: OutlinedButton.icon(
                      key: notMemberSignOutKey,
                      onPressed: _busy ? null : _signOut,
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.authSignOut),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
