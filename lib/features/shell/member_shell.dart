import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// The signed-in frame: five tabs on a pill-indicator [NavigationBar].
/// Tab order matches the branch order in `lib/app/router.dart`:
/// Home, Classes, Check-in, Payments, Profile. Each tab keeps its own
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
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event_rounded),
            label: l10n.tabClasses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.qr_code_2_outlined),
            selectedIcon: const Icon(Icons.qr_code_2_rounded),
            label: l10n.tabCheckin,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.tabPayments,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
