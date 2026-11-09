import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/year_month.dart';
import 'package:logfitness_membership_flutter/features/attendance/attendance_colors.dart';
import 'package:logfitness_membership_flutter/features/attendance/calendar_logic.dart';

int _countDays(List<List<int?>> grid) =>
    grid.expand((List<int?> r) => r).whereType<int>().length;

void main() {
  group('buildMonthGrid', () {
    test('always 6 rows of 7', () {
      for (final YearMonth m in <YearMonth>[
        const YearMonth(2026, 2),
        const YearMonth(2026, 11),
        const YearMonth(2026, 8),
      ]) {
        final grid = buildMonthGrid(m);
        expect(grid.length, 6);
        expect(grid.every((r) => r.length == 7), isTrue);
      }
    });

    test('Monday-first leading blanks', () {
      // 1 Nov 2026 is a Sunday: six leading blanks.
      var grid = buildMonthGrid(const YearMonth(2026, 11));
      expect(grid[0].take(6), everyElement(isNull));
      expect(grid[0][6], 1);
      // 1 Jun 2026 is a Monday: no blanks.
      grid = buildMonthGrid(const YearMonth(2026, 6));
      expect(grid[0][0], 1);
      // 1 Jul 2026 is a Wednesday: two blanks.
      grid = buildMonthGrid(const YearMonth(2026, 7));
      expect(grid[0].take(2), everyElement(isNull));
      expect(grid[0][2], 1);
    });

    test('28 / 29 / 30 / 31-day months', () {
      expect(_countDays(buildMonthGrid(const YearMonth(2026, 2))), 28);
      expect(_countDays(buildMonthGrid(const YearMonth(2028, 2))), 29);
      expect(_countDays(buildMonthGrid(const YearMonth(2026, 4))), 30);
      expect(_countDays(buildMonthGrid(const YearMonth(2026, 12))), 31);
    });

    test('days run in order and the last day is present', () {
      final List<int> flat = buildMonthGrid(
        const YearMonth(2026, 10),
      ).expand((r) => r).whereType<int>().toList();
      expect(flat, List<int>.generate(31, (i) => i + 1));
    });
  });

  group('YearMonth', () {
    test('addMonths wraps years', () {
      expect(const YearMonth(2026, 1).addMonths(-1), const YearMonth(2025, 12));
      expect(const YearMonth(2026, 12).addMonths(1), const YearMonth(2027, 1));
      expect(
        const YearMonth(2026, 11).addMonths(-24),
        const YearMonth(2024, 11),
      );
    });
  });

  group('navigation bounds', () {
    const YearMonth now = YearMonth(2026, 11);

    test('cannot go into the future', () {
      expect(canGoNext(now, now), isFalse);
      expect(canGoNext(now.addMonths(-1), now), isTrue);
    });

    test('earliest is 24 months back', () {
      expect(earliestMonth(now), const YearMonth(2024, 11));
      expect(canGoPrevious(const YearMonth(2024, 12), now), isTrue);
      expect(canGoPrevious(const YearMonth(2024, 11), now), isFalse);
    });

    test('clampMonth', () {
      expect(clampMonth(const YearMonth(2030, 1), now), now);
      expect(clampMonth(const YearMonth(2000, 1), now), earliestMonth(now));
      expect(
        clampMonth(const YearMonth(2026, 3), now),
        const YearMonth(2026, 3),
      );
    });
  });

  group('status mapping', () {
    test('present: green fill + check', () {
      final s = specFor(AttendanceDayStatus.present);
      expect(s.filled, isTrue);
      expect(s.icon, AttendanceGlyph.check);
    });

    test('absent: red fill + cross', () {
      final s = specFor(AttendanceDayStatus.absent);
      expect(s.filled, isTrue);
      expect(s.icon, AttendanceGlyph.cross);
    });

    test('off and holiday: outlined with distinct dots', () {
      final off = specFor(AttendanceDayStatus.off);
      final holiday = specFor(AttendanceDayStatus.holiday);
      expect(off.outlined && holiday.outlined, isTrue);
      expect(off.filled || holiday.filled, isFalse);
      expect(off.dot, AttendanceDot.hollow);
      expect(holiday.dot, AttendanceDot.solid);
    });

    test('none: plain dimmed number', () {
      final s = specFor(AttendanceDayStatus.none);
      expect(s.dimmed, isTrue);
      expect(s.filled || s.outlined || s.icon != null, isFalse);
      expect(s.dot, AttendanceDot.none);
    });

    test('every status is distinguishable without colour', () {
      final shapes = AttendanceDayStatus.values.map((st) {
        final s = specFor(st);
        return (s.icon, s.dot, s.outlined, s.dimmed);
      }).toSet();
      expect(shapes.length, AttendanceDayStatus.values.length);
    });
  });

  group('model', () {
    test('parses the RPC payload; unknown status degrades to none', () {
      final AttendanceCalendar c = AttendanceCalendar.fromJson(
        <String, dynamic>{
          'days': <Map<String, dynamic>>[
            <String, dynamic>{
              'date': '2026-11-03',
              'status': 'present',
              'label': null,
            },
            <String, dynamic>{
              'date': '2026-11-04',
              'status': 'holiday',
              'label': 'Dashain',
            },
            <String, dynamic>{'date': '2026-11-05', 'status': 'surprise'},
          ],
          'summary': <String, dynamic>{'present': 12, 'absent': 3},
          'today': '2026-11-09',
        },
      );
      expect(c.summary.present, 12);
      expect(c.summary.absent, 3);
      expect(c.today, DateTime.utc(2026, 11, 9));
      expect(c.days[0].date, DateTime.utc(2026, 11, 3));
      expect(c.days[1].label, 'Dashain');
      expect(c.days[2].status, AttendanceDayStatus.none);
      expect(isQuietMonth(c), isFalse);
    });

    test('empty month is quiet', () {
      final AttendanceCalendar c = AttendanceCalendar.fromJson(
        <String, dynamic>{
          'days': <dynamic>[],
          'summary': <String, dynamic>{'present': 0, 'absent': 0},
          'today': '2026-11-09',
        },
      );
      expect(isQuietMonth(c), isTrue);
    });
  });

  group('colours', () {
    test('glyph-on-fill contrast >= 4.5:1 in both themes', () {
      for (final AttendanceColors c in <AttendanceColors>[
        AttendanceColors.light,
        AttendanceColors.dark,
      ]) {
        expect(
          AttendanceColors.contrast(c.presentFill, c.onPresent),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          AttendanceColors.contrast(c.absentFill, c.onAbsent),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('fills stand apart from the card surface', () {
      expect(
        AttendanceColors.contrast(
          AttendanceColors.light.presentFill,
          const Color(0xFFF3F4F6),
        ),
        greaterThan(3),
      );
      expect(
        AttendanceColors.contrast(
          AttendanceColors.dark.presentFill,
          const Color(0xFF1B1C22),
        ),
        greaterThan(3),
      );
    });
  });
}
