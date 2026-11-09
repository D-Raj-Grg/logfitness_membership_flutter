import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_membership_flutter/features/auth/login_screen.dart';
import 'package:logfitness_membership_flutter/features/auth/not_member_screen.dart';
import 'package:logfitness_membership_flutter/features/auth/splash_screen.dart';
import 'package:logfitness_membership_flutter/features/bookings/bookings_screen.dart';
import 'package:logfitness_membership_flutter/features/classes/classes_screen.dart';
import 'package:logfitness_membership_flutter/features/home/home_screen.dart';
import 'package:logfitness_membership_flutter/features/messages/messages_screen.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_screen.dart';
import 'package:logfitness_membership_flutter/features/profile/profile_screen.dart';
import 'package:logfitness_membership_flutter/features/qr/qr_screen.dart';
import 'package:logfitness_membership_flutter/features/shell/member_shell.dart';
import 'package:logfitness_membership_flutter/supabase/principal.dart';

/// Every route path in the app. Navigate with `context.go(AppRoutes.x)` /
/// `context.push(AppRoutes.messages)`; never hard-code a path string.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String notMember = '/not-member';

  // Shell tabs (bottom navigation, in order).
  static const String home = '/home';
  static const String classes = '/classes';
  static const String checkin = '/checkin';
  static const String payments = '/payments';
  static const String profile = '/profile';

  // Pushed over the shell (no bottom bar).
  static const String messages = '/messages';
  static const String bookings = '/bookings';
}

const Set<String> _preAuthPaths = <String>{
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.notMember,
};

/// The single redirect decision. Pure, so it is unit-tested per principal.
/// Navigation only -- RLS is the access boundary.
String? redirectFor(Principal principal, String location) {
  String? go(String target) => location == target ? null : target;

  return switch (principal) {
    PrincipalLoading() => go(AppRoutes.splash),
    SignedOut() => go(AppRoutes.login),
    NotMember() => go(AppRoutes.notMember),
    MemberPrincipal() =>
      _preAuthPaths.contains(location) ? AppRoutes.home : null,
  };
}

/// Bumps whenever [principalProvider] changes so [GoRouter] re-evaluates its
/// redirect.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(principalProvider, (previous, next) => notifyListeners());
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// The app's single [GoRouter]. Feature agents: add sub-routes inside your own
/// tab's `GoRoute(routes: [...])` below, or as a top-level route for a screen
/// that should cover the bottom bar.
final goRouterProvider = Provider<GoRouter>((ref) {
  final RouterRefreshNotifier refresh = RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(ref.read(principalProvider), state.matchedLocation),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.notMember,
        builder: (context, state) => const NotMemberScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MemberShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.classes,
                builder: (context, state) => const ClassesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.checkin,
                builder: (context, state) => const QrScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.payments,
                builder: (context, state) => const PaymentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Pushed over the shell: reachable from Home / Profile.
      GoRoute(
        path: AppRoutes.messages,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BookingsScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
