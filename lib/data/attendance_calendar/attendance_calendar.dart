// Mirrors the jsonb answer of the `my_attendance_calendar(p_year, p_month)`
// RPC. Every date is an org-timezone calendar day (a plain date), including
// `today`: the phone's clock never decides what day it is at the gym.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_membership_flutter/domain/format/plain_date.dart';

part 'attendance_calendar.freezed.dart';
part 'attendance_calendar.g.dart';

/// What the server says about one day. Wire values match the RPC exactly; an
/// unknown future value degrades to [none] rather than breaking the screen.
enum AttendanceDayStatus { present, absent, off, holiday, none }

@freezed
abstract class AttendanceDay with _$AttendanceDay {
  const factory AttendanceDay({
    @PlainDateConverter() required DateTime date,
    @JsonKey(unknownEnumValue: AttendanceDayStatus.none)
    required AttendanceDayStatus status,
    // Holiday name when [status] is holiday, otherwise null.
    String? label,
  }) = _AttendanceDay;

  factory AttendanceDay.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDayFromJson(json);
}

@freezed
abstract class AttendanceSummary with _$AttendanceSummary {
  const factory AttendanceSummary({
    @Default(0) int present,
    @Default(0) int absent,
  }) = _AttendanceSummary;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);
}

@freezed
abstract class AttendanceCalendar with _$AttendanceCalendar {
  const factory AttendanceCalendar({
    @Default(<AttendanceDay>[]) List<AttendanceDay> days,
    @Default(AttendanceSummary()) AttendanceSummary summary,
    // The org-timezone "today" the server used to classify the days.
    @PlainDateConverter() required DateTime today,
  }) = _AttendanceCalendar;

  factory AttendanceCalendar.fromJson(Map<String, dynamic> json) =>
      _$AttendanceCalendarFromJson(json);
}
