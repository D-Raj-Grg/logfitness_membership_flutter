import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/supabase/app_claims.dart';
import 'package:logfitness_membership_flutter/supabase/principal.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _user = User(
  id: 'u1',
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00Z',
);

Session _session() => Session(
  accessToken:
      'h.${base64Url.encode(utf8.encode('{}')).replaceAll('=', '')}.s',
  tokenType: 'bearer',
  user: _user,
);

ProviderContainer _container({
  Session? session,
  AppClaims? claims,
  Future<void> Function()? refresh,
}) {
  final c = ProviderContainer(
    overrides: [
      sessionProvider.overrideWithValue(session),
      claimsProvider.overrideWithValue(claims),
      sessionRefresherProvider.overrideWithValue(refresh ?? () async {}),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('no session is signed out', () {
    expect(_container().read(principalProvider), isA<SignedOut>());
  });

  test('member claims make a member', () {
    final p = _container(
      session: _session(),
      claims: const AppClaims(
        orgId: 'o',
        branchIds: <String>[],
        memberId: 'm',
      ),
    ).read(principalProvider);
    expect(p, isA<MemberPrincipal>());
  });

  test('a staff-only token is not a member', () {
    final p = _container(
      session: _session(),
      claims: const AppClaims(
        orgId: 'o',
        branchIds: <String>[],
        staffRole: 'manager',
      ),
    ).read(principalProvider);
    expect(p, isA<NotMember>());
  });

  test('a session without claims is loading, refreshes once, then NotMember',
      () async {
    var refreshes = 0;
    final c = _container(
      session: _session(),
      refresh: () async => refreshes++,
    );
    expect(c.read(principalProvider), isA<PrincipalLoading>());
    await Future<void>.delayed(Duration.zero);
    expect(refreshes, 1);
    expect(c.read(principalProvider), isA<NotMember>());
  });
}
