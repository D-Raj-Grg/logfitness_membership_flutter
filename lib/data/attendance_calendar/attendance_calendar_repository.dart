// The member's attendance calendar, read with the `my_attendance_calendar`
// RPC. Read-only; the database resolves the caller from the JWT, so there is
// deliberately no member id here.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/year_month.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

export 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar.dart';
export 'package:logfitness_membership_flutter/data/attendance_calendar/year_month.dart';

abstract interface class AttendanceCalendarRepository {
  Future<AttendanceCalendar> month(YearMonth month);
}

class SupabaseAttendanceCalendarRepository
    implements AttendanceCalendarRepository {
  const SupabaseAttendanceCalendarRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AttendanceCalendar> month(YearMonth month) => guardFailures(() async {
    final Object? data = await _client.rpc(
      'my_attendance_calendar',
      params: <String, dynamic>{'p_year': month.year, 'p_month': month.month},
    );
    if (data is! Map<String, dynamic>) {
      throw const AppFailure(
        FailureKind.unknown,
        'Could not read your attendance. Please try again.',
      );
    }
    return AttendanceCalendar.fromJson(data);
  });
}

final attendanceCalendarRepositoryProvider =
    Provider<AttendanceCalendarRepository>((ref) {
      return SupabaseAttendanceCalendarRepository(
        ref.watch(supabaseClientProvider),
      );
    });
