// Member-side class reads and the two booking RPCs.
//
// Reads rely on RLS: a member sees only sessions at their home branch and only
// their own bookings (20260905160000_classes_schema.sql), so no branch or
// member filter is applied here. Writes go exclusively through
// `book_class_session` / `cancel_class_booking` -- members hold no write
// policy on `class_bookings`. Both RPCs return jsonb:
//   book:   {booking_id, status ('booked'|'waitlisted'), session_id, member_id, booked_at}
//   cancel: {booking_id, status, cancelled_at, cancelled_by_staff, promoted_booking_id}
// Refusals arrive as `check_violation` / `no_data_found` / `unique_violation`
// with a sentence written for a person ("This class session has already
// started", "Bookings can only be cancelled at least 120 minutes before the
// class starts"); `mapError` passes them through verbatim.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

class BookResult {
  const BookResult({required this.bookingId, required this.status});
  final String bookingId;
  final ClassBookingStatus status;
}

class ClassesRepository {
  const ClassesRepository(this._client);

  final SupabaseClient _client;

  /// Scheduled sessions that have not started, soonest first.
  Future<List<ClassSession>> listUpcomingSessions({int limit = 120}) {
    return guardFailures(() async {
      final List<dynamic> rows = await _client
          .from('class_sessions')
          .select(
            'id, class_id, starts_at, ends_at, capacity, booked_count, '
            'classes(name, room, description)',
          )
          .eq('status', 'scheduled')
          .gt('starts_at', DateTime.now().toUtc().toIso8601String())
          .order('starts_at', ascending: true)
          .limit(limit);
      return rows
          .map((r) => ClassSession.fromJson(r as Map<String, dynamic>))
          .toList(growable: false);
    });
  }

  /// The caller's own bookings, most recently booked first.
  Future<List<ClassBooking>> listMyBookings({int limit = 100}) {
    return guardFailures(() async {
      final List<dynamic> rows = await _client
          .from('class_bookings')
          .select(
            'id, session_id, status, booked_at, '
            'class_sessions(starts_at, ends_at, status, classes(name, room))',
          )
          .order('booked_at', ascending: false)
          .limit(limit);
      return rows
          .map((r) => ClassBooking.fromJson(r as Map<String, dynamic>))
          .toList(growable: false);
    });
  }

  Future<BookResult> book(String sessionId) {
    return guardFailures(() async {
      final Object? res = await _client.rpc(
        'book_class_session',
        params: rpcParams(<String, dynamic>{'p_session_id': sessionId}),
      );
      final Map<String, dynamic> map = res! as Map<String, dynamic>;
      return BookResult(
        bookingId: map['booking_id'] as String,
        status: ClassBookingStatus.fromDb(map['status'] as String),
      );
    });
  }

  Future<void> cancel(String bookingId, {String? reason}) {
    return guardFailures(() async {
      await _client.rpc(
        'cancel_class_booking',
        params: rpcParams(<String, dynamic>{
          'p_booking_id': bookingId,
          'p_reason': reason,
        }),
      );
    });
  }
}

final classesRepositoryProvider = Provider<ClassesRepository>((ref) {
  return ClassesRepository(ref.watch(supabaseClientProvider));
});
