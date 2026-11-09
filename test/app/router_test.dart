import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:logfitness_membership_flutter/app/features.dart';
import 'package:logfitness_membership_flutter/app/router.dart';
import 'package:logfitness_membership_flutter/supabase/app_claims.dart';
import 'package:logfitness_membership_flutter/supabase/principal.dart';

void main() {
  const member = MemberPrincipal(
    AppClaims(orgId: 'o', branchIds: <String>['b'], memberId: 'm'),
  );

  group('redirectFor', () {
    test('loading always shows the splash', () {
      expect(
        redirectFor(const PrincipalLoading(), AppRoutes.home),
        AppRoutes.splash,
      );
      expect(redirectFor(const PrincipalLoading(), AppRoutes.splash), isNull);
    });

    test('signed out is confined to /login', () {
      expect(
        redirectFor(const SignedOut(), AppRoutes.home),
        AppRoutes.login,
      );
      expect(redirectFor(const SignedOut(), AppRoutes.splash), AppRoutes.login);
      expect(redirectFor(const SignedOut(), AppRoutes.login), isNull);
      expect(
        redirectFor(const SignedOut(), AppRoutes.messages),
        AppRoutes.login,
      );
    });

    test('not-a-member is confined to /not-member', () {
      expect(
        redirectFor(const NotMember(), AppRoutes.home),
        AppRoutes.notMember,
      );
      expect(redirectFor(const NotMember(), AppRoutes.login), AppRoutes.notMember);
      expect(redirectFor(const NotMember(), AppRoutes.notMember), isNull);
    });

    test('a member leaves the pre-auth screens for /home', () {
      for (final path in <String>[
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.notMember,
      ]) {
        expect(redirectFor(member, path), AppRoutes.home, reason: path);
      }
    });

    test('a member may be anywhere in the shell or pushed routes', () {
      for (final path in <String>[
        AppRoutes.home,
        AppRoutes.attendance,
        AppRoutes.checkin,
        AppRoutes.payments,
        AppRoutes.profile,
        AppRoutes.messages,
      ]) {
        expect(redirectFor(member, path), isNull, reason: path);
      }
    });

    test('the enabled tabs are Home, Attendance, Check-in, Payments, Profile', () {
      expect(enabledTabs, <MemberTab>[
        MemberTab.home,
        MemberTab.attendance,
        MemberTab.checkin,
        MemberTab.payments,
        MemberTab.profile,
      ]);
    });

    test('Classes and Bookings are not registered while classes are off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(goRouterProvider);
      final paths = <String>{};
      void collect(List<RouteBase> routes) {
        for (final route in routes) {
          if (route is GoRoute) {
            paths.add(route.path);
          }
          collect(route.routes);
        }
      }

      collect(router.configuration.routes);
      expect(paths, contains(AppRoutes.attendance));
      expect(paths, contains(AppRoutes.messages));
      expect(paths, isNot(contains(AppRoutes.bookings)));
      expect(paths, isNot(contains(AppRoutes.classes)));
    });
  });
}
