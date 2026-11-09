import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_membership_flutter/app/features.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// The signed-in frame: the tabs in [enabledTabs] on a pill-indicator [NavigationBar].
/// Tab order matches the branch order in `lib/app/router.dart` (both come from
/// [enabledTabs]): Home, Attendance, Check-in, Payments, Profile. Each tab keeps its own
/// navigation stack and scroll position (indexedStack).
class MemberShell extends StatelessWidget {
  const MemberShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => navigationShell.goBranch(
          index,
          // Tapping the active tab pops it back to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: <NavigationDestination>[
          for (final MemberTab tab in enabledTabs) _destination(tab, l10n),
        ],
      ),
    );
  }
}

NavigationDestination _destination(MemberTab tab, AppLocalizations l10n) {
  final (IconData icon, IconData selected, String label) = switch (tab) {
    MemberTab.home => (Icons.home_outlined, Icons.home_rounded, l10n.tabHome),
    MemberTab.classes => (
      Icons.event_outlined,
      Icons.event_rounded,
      l10n.tabClasses,
    ),
    MemberTab.attendance => (
      Icons.calendar_month_outlined,
      Icons.calendar_month_rounded,
      l10n.tabAttendance,
    ),
    MemberTab.checkin => (
      Icons.qr_code_scanner_outlined,
      Icons.qr_code_scanner_rounded,
      l10n.tabCheckin,
    ),
    MemberTab.payments => (
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      l10n.tabPayments,
    ),
    MemberTab.profile => (
      Icons.person_outline_rounded,
      Icons.person_rounded,
      l10n.tabProfile,
    ),
  };
  return NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selected),
    label: label,
  );
}
