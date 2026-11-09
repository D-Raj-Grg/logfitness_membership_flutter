// A member's own plan history (read-only; renewals are requests the desk
// fulfils). RLS scopes the query to the signed-in member.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/memberships/membership.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

List<Membership> membershipsFromRows(List<Map<String, dynamic>> rows) =>
    rows.map(Membership.fromJson).toList();

class MembershipsRepository {
  const MembershipsRepository(this._client);

  final SupabaseClient _client;

  /// Newest first. A renewal inserts a new row rather than extending the old
  /// one, so this is the record of what was sold and when.
  Future<List<Membership>> listMemberships() => guardFailures(() async {
    final PostgrestList rows = await _client
        .from('memberships')
        .select(
          'id, plan_id, plan_name, plan_type, start_date, end_date, '
          'sessions_total, sessions_remaining, price_paisa, discount_paisa, '
          'status, created_at',
        )
        .order('start_date', ascending: false)
        // Two memberships can share a start date; created_at keeps the order
        // things actually happened.
        .order('created_at', ascending: false);
    return membershipsFromRows(rows);
  });
}

final membershipsRepositoryProvider = Provider<MembershipsRepository>((ref) {
  return MembershipsRepository(ref.watch(supabaseClientProvider));
});

/// The member's plan history, newest first.
final membershipsProvider = FutureProvider<List<Membership>>((ref) {
  return ref.watch(membershipsRepositoryProvider).listMemberships();
});
