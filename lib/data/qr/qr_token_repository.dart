// Mints the member's check-in QR token with the `mint_qr_token` Postgres RPC.
// Not an Edge Function. With no `p_member_id` the function resolves the caller
// from the JWT; a member can only ever mint for themselves.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/qr/qr_token.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

export 'package:logfitness_membership_flutter/data/qr/qr_token.dart';

class QrTokenRepository {
  const QrTokenRepository(this._client);

  final SupabaseClient _client;

  /// Mints a fresh token (server default TTL, 90 s).
  Future<QrToken> mint() => guardFailures(() async {
    final dynamic res = await _client.rpc('mint_qr_token');
    return QrToken.fromJson(res as Map<String, dynamic>);
  });
}

final qrTokenRepositoryProvider = Provider<QrTokenRepository>((ref) {
  return QrTokenRepository(ref.watch(supabaseClientProvider));
});
