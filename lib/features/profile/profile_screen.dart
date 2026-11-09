import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/app/locale_controller.dart';
import 'package:logfitness_membership_flutter/app/router.dart';
import 'package:logfitness_membership_flutter/app/theme_mode_controller.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/member/my_card.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/section_header.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key profileSignOutKey = Key('profile-sign-out');
const Key profileSignOutConfirmKey = Key('profile-sign-out-confirm');
const Key profileLanguageKey = Key('profile-language');
const Key profileThemeKey = Key('profile-theme');

/// "1.2.3 (45)". Overridable in tests (no platform channel there).
final appVersionProvider = FutureProvider<String>((ref) async {
  final PackageInfo info = await PackageInfo.fromPlatform();
  return info.buildNumber.isEmpty
      ? info.version
      : '${info.version} (${info.buildNumber})';
});

/// Two-letter initials from a full name: first + last word.
String initialsOf(String fullName) {
  final List<String> parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  final String first = String.fromCharCode(parts.first.runes.first);
  if (parts.length == 1) {
    return first.toUpperCase();
  }
  final String last = String.fromCharCode(parts.last.runes.first);
  return (first + last).toUpperCase();
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.profileSignOutConfirmTitle),
        content: Text(l10n.profileSignOutConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: profileSignOutConfirmKey,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      // The principal flips to signed-out and the router returns to /login.
      await ref.read(memberAuthRepositoryProvider).signOut();
    } catch (e, st) {
      if (context.mounted) {
        showErrorSnackBar(context, e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<CurrentMember> me = ref.watch(memberSelfProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Brand.gutter,
            Brand.spaceSm,
            Brand.gutter,
            Brand.spaceXl,
          ),
          children: <Widget>[
            me.when(
              loading: () => const Column(
                children: <Widget>[
                  SkeletonBox(width: 72, height: 72, radius: 36),
                  SizedBox(height: Brand.spaceMd),
                  SkeletonBox(height: 180, radius: Brand.radiusCard),
                ],
              ),
              error: (Object e, StackTrace st) => FailureView(
                failure: mapError(e, st),
                onRetry: () => ref.invalidate(memberSelfProvider),
              ),
              data: (CurrentMember m) => _Details(member: m),
            ),
            SectionHeader(title: l10n.profileSectionPreferences),
            const _Preferences(),
            SectionHeader(title: l10n.profileSectionAbout),
            LogCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(l10n.profileVersion),
                    trailing: Text(
                      ref.watch(appVersionProvider).value ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(l10n.profileMessages),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.messages),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Brand.spaceLg),
            SizedBox(
              height: Brand.buttonHeight,
              child: OutlinedButton.icon(
                key: profileSignOutKey,
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout),
                label: Text(l10n.profileSignOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.member});

  final CurrentMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MyCard? card = ref.watch(myCardProvider).value;

    Widget row(String name, String value) => ListTile(
      title: Text(name, style: theme.textTheme.bodyMedium),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.5,
        ),
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    final Widget divider = Divider(height: 1, color: scheme.outlineVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Semantics(
            excludeSemantics: true,
            child: CircleAvatar(
              radius: 38,
              backgroundColor: scheme.primary,
              child: Text(
                initialsOf(member.fullName),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Brand.spaceMd),
        Text(
          member.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: Brand.spaceXs),
        Text(
          member.orgName,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        SectionHeader(title: l10n.profileSectionDetails),
        LogCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              row(l10n.profileMemberCode, member.memberCode),
              divider,
              row(
                l10n.profileCardNo,
                card?.cardNoText == null
                    ? l10n.profileNoCard
                    : l10n.homeCardNo(card!.cardNoText!),
              ),
              divider,
              row(l10n.profileBranch, member.homeBranchName),
              divider,
              row(l10n.profilePhone, member.phone),
            ],
          ),
        ),
      ],
    );
  }
}

class _Preferences extends ConsumerWidget {
  const _Preferences();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Locale? override = ref.watch(localeProvider);
    // Show the language actually in effect, override or device.
    final String activeLanguage =
        override?.languageCode ?? Localizations.localeOf(context).languageCode;
    final ThemeMode mode = ref.watch(themeModeProvider);

    return LogCard(
      padding: const EdgeInsets.all(Brand.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.profileLanguage, style: theme.textTheme.labelLarge),
          const SizedBox(height: Brand.spaceSm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              key: profileLanguageKey,
              showSelectedIcon: false,
              segments: <ButtonSegment<String>>[
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(l10n.profileLanguageEnglish),
                ),
                ButtonSegment<String>(
                  value: 'ne',
                  label: Text(l10n.profileLanguageNepali),
                ),
              ],
              selected: <String>{activeLanguage == 'ne' ? 'ne' : 'en'},
              onSelectionChanged: (Set<String> s) =>
                  ref.read(localeProvider.notifier).set(Locale(s.first)),
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          Text(l10n.profileTheme, style: theme.textTheme.labelLarge),
          const SizedBox(height: Brand.spaceSm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              key: profileThemeKey,
              showSelectedIcon: false,
              segments: <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(l10n.profileThemeSystem),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(l10n.profileThemeLight),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(l10n.profileThemeDark),
                ),
              ],
              selected: <ThemeMode>{mode},
              onSelectionChanged: (Set<ThemeMode> s) =>
                  ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
        ],
      ),
    );
  }
}
