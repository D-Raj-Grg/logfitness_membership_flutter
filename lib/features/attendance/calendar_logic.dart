// Pure logic behind the attendance calendar: grid layout, navigation bounds,
// and the status -> cell mapping. No widgets, so it is trivially testable.
import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/year_month.dart';

/// How far back a member can browse.
const int kAttendanceMonthsBack = 24;

/// The month grid: always 6 rows x 7 columns, Monday first. Each entry is the
/// day of month, or null for a leading / trailing blank.
List<List<int?>> buildMonthGrid(YearMonth month) {
  final int leading = month.firstWeekday - 1;
  final int days = month.daysInMonth;
  return List<List<int?>>.generate(6, (int row) {
    return List<int?>.generate(7, (int col) {
      final int day = row * 7 + col - leading + 1;
      return day >= 1 && day <= days ? day : null;
    });
  });
}

/// Earliest browsable month relative to the current one.
YearMonth earliestMonth(YearMonth current) =>
    current.addMonths(-kAttendanceMonthsBack);

bool canGoPrevious(YearMonth selected, YearMonth current) =>
    selected > earliestMonth(current);

bool canGoNext(YearMonth selected, YearMonth current) => selected < current;

/// Clamps [month] into the browsable window.
YearMonth clampMonth(YearMonth month, YearMonth current) {
  final YearMonth lo = earliestMonth(current);
  if (month < lo) return lo;
  if (month > current) return current;
  return month;
}

/// Indexes the server's days by day of month (only days inside [month]).
Map<int, AttendanceDay> indexDays(
  AttendanceCalendar calendar,
  YearMonth month,
) {
  final Map<int, AttendanceDay> byDay = <int, AttendanceDay>{};
  for (final AttendanceDay d in calendar.days) {
    if (d.date.year == month.year && d.date.month == month.month) {
      byDay[d.date.day] = d;
    }
  }
  return byDay;
}

/// True when the month has nothing to show: no present or absent days.
bool isQuietMonth(AttendanceCalendar calendar) =>
    calendar.summary.present == 0 && calendar.summary.absent == 0;

/// How a status is drawn. Colour is never the only signal: every status has
/// its own icon or marker shape.
class AttendanceCellSpec {
  const AttendanceCellSpec({
    this.filled = false,
    this.icon,
    this.outlined = false,
    this.dot = AttendanceDot.none,
    this.dimmed = false,
  });

  /// Solid status-coloured fill.
  final bool filled;

  /// Check or cross glyph drawn over a filled cell.
  final AttendanceGlyph? icon;

  /// Neutral outline instead of a fill.
  final bool outlined;
  final AttendanceDot dot;

  /// Plain number, drawn quietly.
  final bool dimmed;
}

enum AttendanceGlyph { check, cross }

enum AttendanceDot { none, hollow, solid }

AttendanceCellSpec specFor(AttendanceDayStatus status) => switch (status) {
  AttendanceDayStatus.present => const AttendanceCellSpec(
    filled: true,
    icon: AttendanceGlyph.check,
  ),
  AttendanceDayStatus.absent => const AttendanceCellSpec(
    filled: true,
    icon: AttendanceGlyph.cross,
  ),
  AttendanceDayStatus.off => const AttendanceCellSpec(
    outlined: true,
    dot: AttendanceDot.hollow,
  ),
  AttendanceDayStatus.holiday => const AttendanceCellSpec(
    outlined: true,
    dot: AttendanceDot.solid,
  ),
  AttendanceDayStatus.none => const AttendanceCellSpec(dimmed: true),
};
