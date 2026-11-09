import 'package:flutter_test/flutter_test.dart';
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
        AppRoutes.classes,
        AppRoutes.checkin,
        AppRoutes.payments,
        AppRoutes.profile,
        AppRoutes.messages,
        AppRoutes.bookings,
      ]) {
        expect(redirectFor(member, path), isNull, reason: path);
      }
    });
  });
}
