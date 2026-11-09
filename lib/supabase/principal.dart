import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/supabase/app_claims.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

/// Who is using the app. The router's single redirect guard switches on this.
sealed class Principal {
  const Principal();
}

/// No session.
final class SignedOut extends Principal {
  const SignedOut();
}

/// A session whose token carries the member claims.
final class MemberPrincipal extends Principal {
  const MemberPrincipal(this.claims);

  final AppClaims claims;
}

/// A valid session that is not a member: the member left, the org is
/// inactive, the account is unlinked, or it is a staff-only token (staff
/// never use this app). Shown a plain "ask the front desk" screen.
final class NotMember extends Principal {
  const NotMember();
}

/// A session exists but it is not yet known whether it is a member (claims not
/// stamped; one refresh in flight). Router shows the splash.
final class PrincipalLoading extends Principal {
  const PrincipalLoading();
}

/// Refreshes the session once so the access-token hook can stamp claims.
/// Overridable in tests.
final sessionRefresherProvider = Provider<Future<void> Function()>((ref) {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  return () async {
    await client.auth.refreshSession();
  };
});

/// Derives the [Principal] from session + claims.
///
///  * no session -> [SignedOut];
///  * claims with `isMember` -> [MemberPrincipal];
///  * claims without member (staff-only token) -> [NotMember];
///  * session with NO claims -> [PrincipalLoading] while ONE `refreshSession`
///    is attempted for that user (a fresh session can predate the hook
///    stamping), then [NotMember] if it still has none;
///  * malformed claims -> [NotMember] (logged). The startup-failure screen is
///    pre-`runApp` only; once running, sign-out + "ask the desk" is the
///    recoverable option.
class PrincipalController extends Notifier<Principal> {
  String? _refreshAttemptedFor;

  @override
  Principal build() {
    final Session? session = ref.watch(sessionProvider);
    if (session == null) {
      _refreshAttemptedFor = null;
      return const SignedOut();
    }

    final AppClaims? claims;
    try {
      claims = ref.watch(claimsProvider);
    } on MalformedClaims catch (e) {
      debugPrint('Malformed claims: $e');
      return const NotMember();
    } on FormatException catch (e) {
      debugPrint('Unreadable access token: $e');
      return const NotMember();
    }

    if (claims != null) {
      return claims.isMember ? MemberPrincipal(claims) : const NotMember();
    }

    final String userId = session.user.id;
    if (_refreshAttemptedFor == userId) {
      return const NotMember();
    }
    _refreshAttemptedFor = userId;
    unawaited(_refreshOnce());
    return const PrincipalLoading();
  }

  Future<void> _refreshOnce() async {
    try {
      await ref.read(sessionRefresherProvider)();
    } catch (e) {
      debugPrint('Session refresh failed: ${e.runtimeType}');
    }
    // A successful refresh emits an auth event, which rebuilds this notifier
    // with the fresh claims. If we are still loading, nothing is coming.
    if (ref.mounted && state is PrincipalLoading) {
      state = const NotMember();
    }
  }
}

final principalProvider = NotifierProvider<PrincipalController, Principal>(
  PrincipalController.new,
);
