// Card number / phone + PIN sign-in (PLANNING.md §4).
//
// The PIN is a secret this app never keeps: it exists only as the `pin`
// argument of [MemberAuthRepository.login], is sent once over TLS in a POST
// body to the `member-login` Edge Function, and is not stored, logged, put in
// an exception, or held by any provider afterwards. Nothing here may ever
// interpolate it into a string.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_config.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

/// Outcome of a login attempt. Business outcomes are values, not exceptions.
sealed class LoginResult {
  const LoginResult();
}

/// Signed in; the session is set and the router will move on by itself.
final class LoginOk extends LoginResult {
  const LoginOk();
}

/// Wrong card/phone, wrong PIN, unassigned card, left member -- deliberately
/// one answer (PLANNING.md §4.3). The UI must not reveal which.
final class LoginInvalid extends LoginResult {
  const LoginInvalid();
}

/// Too many wrong PINs for this member.
final class LoginLocked extends LoginResult {
  const LoginLocked(this.retryAfterSeconds);

  final int retryAfterSeconds;
}

/// Per-IP / per-org throttle tripped; ask the member to wait.
final class LoginRateLimited extends LoginResult {
  const LoginRateLimited();
}

/// Transport or server failure (offline, 5xx, malformed response).
final class LoginFailed extends LoginResult {
  const LoginFailed(this.failure);

  final AppFailure failure;
}

abstract interface class MemberAuthRepository {
  /// [identifier]: digits only; 1-4 digits = printed card number, 7+ = phone.
  Future<LoginResult> login({
    required String identifier,
    required String pin,
  });

  /// Ends this phone's session and clears the stored refresh token.
  Future<void> signOut();
}

/// The body may arrive already decoded or, on some non-2xx paths, as a JSON
/// string. Anything else is "no body".
Map<String, dynamic>? _asMap(Object? body) {
  if (body is Map<String, dynamic>) {
    return body;
  }
  if (body is String && body.isNotEmpty) {
    try {
      final Object? decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
  return null;
}

/// Maps a `member-login` response to a [LoginResult] for the non-`ok` cases.
///
/// [status] is the HTTP status when known; [body] the decoded JSON. Anything
/// unrecognised is [LoginFailed] rather than [LoginInvalid], so a server
/// regression is not disguised as "wrong PIN".
LoginResult mapLoginResponse(int? status, Object? body) {
  final Map<String, dynamic>? map = _asMap(body);
  final Object? result = map?['result'];

  switch (result) {
    case 'invalid':
      return const LoginInvalid();
    case 'locked':
      final Object? secs = map?['retry_after_seconds'];
      return LoginLocked(secs is num ? secs.ceil() : 0);
    case 'rate_limited':
      return const LoginRateLimited();
  }
  if (status == 429) {
    return const LoginRateLimited();
  }
  return const LoginFailed(
    AppFailure(FailureKind.unknown, 'Could not sign in. Please try again.'),
  );
}

class SupabaseMemberAuthRepository implements MemberAuthRepository {
  SupabaseMemberAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<LoginResult> login({
    required String identifier,
    required String pin,
  }) async {
    try {
      // `functions.invoke` POSTs JSON to `${SUPABASE_URL}/functions/v1/member-login`
      // with `apikey` = publishable key and `Authorization: Bearer <session
      // token, or the publishable key when signed out>`. Nothing else is
      // attached. The function has verify_jwt off.
      final FunctionResponse response = await _client.functions.invoke(
        'member-login',
        body: <String, dynamic>{
          'org_slug': SupabaseConfig.orgSlug,
          'identifier': identifier,
          'pin': pin,
        },
      );

      final Object? data = response.data;
      if (data is Map<String, dynamic> && data['result'] == 'ok') {
        final Object? refresh = data['refresh_token'];
        if (refresh is! String || refresh.isEmpty) {
          return mapLoginResponse(response.status, null);
        }
        await _client.auth.setSession(refresh);
        return const LoginOk();
      }
      return mapLoginResponse(response.status, data);
    } on FunctionException catch (e) {
      // Non-2xx. The business outcomes may arrive this way (401/423/429).
      return mapLoginResponse(e.status, e.details);
    } catch (e, st) {
      // `mapError` keeps the original error as `cause`, which here can only be
      // a transport/auth exception -- none of them carry request bodies.
      return LoginFailed(mapError(e, st));
    }
  }

  @override
  Future<void> signOut() async {
    // Local scope: ends this phone only. Global would sign the member out of
    // every other device too.
    await _client.auth.signOut(scope: SignOutScope.local);
  }
}

final memberAuthRepositoryProvider = Provider<MemberAuthRepository>((ref) {
  return SupabaseMemberAuthRepository(ref.watch(supabaseClientProvider));
});
