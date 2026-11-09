import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

/// Answer of the `request_renewal` RPC.
enum RenewalResult {
  /// Filed (or counted on the one pending row).
  ok,

  /// Asked again within the server's cooldown; the first request stands.
  tooSoon,

  /// Not a live member any more.
  noMember;

  static RenewalResult? parse(Object? raw) => switch (raw) {
    'ok' => RenewalResult.ok,
    'too_soon' => RenewalResult.tooSoon,
    'no_member' => RenewalResult.noMember,
    _ => null,
  };
}

abstract interface class RenewalRepository {
  Future<RenewalResult> requestRenewal({String? phone, String? note});
}

class SupabaseRenewalRepository implements RenewalRepository {
  const SupabaseRenewalRepository(this._client);

  final SupabaseClient _client;

  /// A renewal is a request the front desk fulfils: this is the only write,
  /// and it goes through the RPC, never a table call.
  @override
  Future<RenewalResult> requestRenewal({String? phone, String? note}) =>
      guardFailures(() async {
        final Object? data = await _client.rpc(
          'request_renewal',
          params: rpcParams(<String, dynamic>{
            'p_phone': _blankToNull(phone),
            'p_note': _blankToNull(note),
          }),
        );
        final RenewalResult? result = RenewalResult.parse(
          data is Map<String, dynamic> ? data['result'] : null,
        );
        if (result == null) {
          // A new server answer this build does not know: say so rather than
          // pretend the request went through.
          throw const AppFailure(
            FailureKind.unknown,
            'Could not send the request. Please try again.',
          );
        }
        return result;
      });

  static String? _blankToNull(String? v) {
    final String? t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

final renewalRepositoryProvider = Provider<RenewalRepository>((ref) {
  return SupabaseRenewalRepository(ref.watch(supabaseClientProvider));
});
