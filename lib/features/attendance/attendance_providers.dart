import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar_repository.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';

/// The org-timezone month the screen opens on. Only a starting point (and the
/// navigation bound until the first response arrives): the response's own
/// `today` is authoritative once loaded. Tests override this.
final attendanceInitialMonthProvider = Provider<YearMonth>((ref) {
  final String tz =
      ref.watch(memberSelfProvider).value?.timezone ?? kDefaultTimezone;
  return YearMonth.of(todayInOrgTimezone(timeZone: tz));
});

/// One month of the calendar. No automatic retry: a failed read shows
/// `FailureView` with a "Try again" button straight away.
final attendanceCalendarProvider =
    FutureProvider.family<AttendanceCalendar, YearMonth>(
      retry: (int count, Object error) => null,
      (ref, YearMonth month) =>
          ref.watch(attendanceCalendarRepositoryProvider).month(month),
    );

/// The month being viewed.
class SelectedMonth extends Notifier<YearMonth> {
  @override
  YearMonth build() => ref.read(attendanceInitialMonthProvider);

  void set(YearMonth month) => state = month;
}

final selectedAttendanceMonthProvider =
    NotifierProvider.autoDispose<SelectedMonth, YearMonth>(SelectedMonth.new);
