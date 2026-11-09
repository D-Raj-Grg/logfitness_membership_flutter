import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/attendance/membership_snapshot.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/domain/format/plain_date.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

abstract interface class AttendanceRepository {
  /// The snapshot for [memberId] (RLS lets a member see only their own).
  /// ONE method on purpose: if the backend adds a member-safe `my_snapshot()`
  /// wrapper, swapping to it is a one-line change in the implementation.
  Future<MembershipSnapshot> fetchSnapshot(String memberId);
}

class SupabaseAttendanceRepository implements AttendanceRepository {
  const SupabaseAttendanceRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<MembershipSnapshot> fetchSnapshot(String memberId) =>
      guardFailures(() async {
        final List<dynamic> rows =
            await _client.rpc(
                  'attendance_snapshot',
                  params: <String, dynamic>{'p_member_id': memberId},
                )
                as List<dynamic>;
        if (rows.isEmpty) {
          return const MembershipSnapshot.empty();
        }
        final MembershipSnapshot snap = MembershipSnapshot.fromRow(
          rows.first as Map<String, dynamic>,
        );
        final String? membershipId = snap.membershipId;
        if (membershipId == null) {
          return snap;
        }
        // The function carries no dates; read them off the membership it
        // picked. Lookup by id, not a tenant filter -- RLS bounds the rows.
        final Map<String, dynamic>? ms = await _client
            .from('memberships')
            .select('start_date,end_date')
            .eq('id', membershipId)
            .maybeSingle();
        if (ms == null) {
          return snap;
        }
        return snap.withDates(
          startDate: _date(ms['start_date']),
          endDate: _date(ms['end_date']),
        );
      });

  static DateTime? _date(Object? raw) =>
      raw is String ? const NullablePlainDateConverter().fromJson(raw) : null;
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return SupabaseAttendanceRepository(ref.watch(supabaseClientProvider));
});
