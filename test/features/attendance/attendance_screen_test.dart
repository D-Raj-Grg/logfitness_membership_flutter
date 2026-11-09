import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/attendance/attendance_providers.dart';
import 'package:logfitness_membership_flutter/features/attendance/attendance_screen.dart';
import 'package:logfitness_membership_flutter/features/attendance/calendar_widgets.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const YearMonth _nov = YearMonth(2026, 11);

AttendanceDay _d(
  int day,
  AttendanceDayStatus s, {
  String? label,
  int month = 11,
}) => AttendanceDay(
  date: DateTime.utc(2026, month, day),
  status: s,
  label: label,
);

AttendanceCalendar _november() => AttendanceCalendar(
  days: <AttendanceDay>[
    _d(2, AttendanceDayStatus.present),
    _d(3, AttendanceDayStatus.present),
    _d(4, AttendanceDayStatus.absent),
    _d(7, AttendanceDayStatus.off),
    _d(8, AttendanceDayStatus.holiday, label: 'Dashain'),
    _d(9, AttendanceDayStatus.none),
  ],
  summary: const AttendanceSummary(present: 12, absent: 3),
  today: DateTime.utc(2026, 11, 9),
);

class _FakeRepo implements AttendanceCalendarRepository {
  _FakeRepo(this.handler);
  final Future<AttendanceCalendar> Function(YearMonth) handler;
  final List<YearMonth> calls = <YearMonth>[];

  @override
  Future<AttendanceCalendar> month(YearMonth month) {
    calls.add(month);
    return handler(month);
  }
}

Widget _app(
  _FakeRepo repo, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) => ProviderScope(
  retry: (int c, Object e) => null,
  overrides: [
    attendanceCalendarRepositoryProvider.overrideWithValue(repo),
    attendanceInitialMonthProvider.overrideWithValue(_nov),
  ],
  child: MaterialApp(
    theme: theme ?? appLightTheme,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const AttendanceScreen(),
  ),
);

IconButton _btn(WidgetTester t, Key k) => t.widget<IconButton>(find.byKey(k));

void main() {
  testWidgets('renders present / absent / off / holiday with semantics', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final repo = _FakeRepo((_) async => _november());
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('November 2026'), findsOneWidget);
    expect(find.byKey(attendanceGridKey), findsOneWidget);
    expect(find.byKey(attendanceLegendKey), findsOneWidget);
    // Weekday header, Monday first.
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);

    // Present = check, absent = cross; never colour alone.
    expect(
      find.byIcon(Icons.check),
      findsNWidgets(2 + 2),
    ); // 2 days + summary + legend
    expect(find.byIcon(Icons.close), findsNWidgets(1 + 2));

    expect(find.bySemanticsLabel('3 November, Present'), findsOneWidget);
    expect(find.bySemanticsLabel('4 November, Absent'), findsOneWidget);
    expect(find.bySemanticsLabel('7 November, Day off'), findsOneWidget);
    expect(
      find.bySemanticsLabel('8 November, Holiday: Dashain'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('9 November, No record'), findsOneWidget);
    expect(find.bySemanticsLabel('12 present, 3 absent'), findsOneWidget);
    expect(repo.calls, <YearMonth>[_nov]);
    handle.dispose();
  });

  testWidgets('summary counts animate to the server numbers', (tester) async {
    await tester.pumpWidget(_app(_FakeRepo((_) async => _november())));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(attendanceSummaryKey),
        matching: find.text('12'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(attendanceSummaryKey),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a holiday opens its name in a sheet', (tester) async {
    await tester.pumpWidget(_app(_FakeRepo((_) async => _november())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(find.byKey(attendanceHolidaySheetKey), findsOneWidget);
    expect(find.text('Dashain'), findsOneWidget);
  });

  testWidgets('cannot navigate into a future month; can go back and forth', (
    tester,
  ) async {
    final repo = _FakeRepo((m) async {
      return m == _nov
          ? _november()
          : AttendanceCalendar(
              summary: const AttendanceSummary(present: 5, absent: 1),
              today: DateTime.utc(2026, 11, 9),
              days: <AttendanceDay>[
                _d(1, AttendanceDayStatus.present, month: 10),
              ],
            );
    });
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(_btn(tester, attendanceNextKey).onPressed, isNull);
    expect(_btn(tester, attendanceNextKey).onPressed, isNull);

    await tester.tap(find.byKey(attendancePrevKey));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('November 2026'), findsNothing);
    expect(repo.calls.last, const YearMonth(2026, 10));
    expect(_btn(tester, attendanceNextKey).onPressed, isNotNull);

    await tester.tap(find.byKey(attendanceNextKey));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
    expect(_btn(tester, attendanceNextKey).onPressed, isNull);
  });

  testWidgets('previous is disabled 24 months back', (tester) async {
    final repo = _FakeRepo(
      (m) async => AttendanceCalendar(today: DateTime.utc(2026, 11, 9)),
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    for (int i = 0; i < 24; i++) {
      expect(
        _btn(tester, attendancePrevKey).onPressed,
        isNotNull,
        reason: '$i',
      );
      await tester.tap(find.byKey(attendancePrevKey));
      await tester.pumpAndSettle();
    }
    expect(find.text('November 2024'), findsOneWidget);
    expect(_btn(tester, attendancePrevKey).onPressed, isNull);
  });

  testWidgets('empty month shows the friendly hint', (tester) async {
    final repo = _FakeRepo(
      (m) async => AttendanceCalendar(today: DateTime.utc(2026, 11, 9)),
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.byKey(asyncEmptyKey), findsOneWidget);
    expect(find.textContaining('No visits recorded'), findsOneWidget);
  });

  testWidgets('loading shows the skeleton', (tester) async {
    final Completer<AttendanceCalendar> never = Completer<AttendanceCalendar>();
    await tester.pumpWidget(_app(_FakeRepo((_) => never.future)));
    await tester.pump();
    expect(find.byKey(attendanceSkeletonKey), findsOneWidget);
  });

  testWidgets('failure shows FailureView and retry reloads', (tester) async {
    int calls = 0;
    final repo = _FakeRepo((_) async {
      calls++;
      if (calls == 1) {
        throw const AppFailure(FailureKind.offline, 'No signal.');
      }
      return _november();
    });
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.byKey(failureViewKey), findsOneWidget);
    expect(find.text('No signal.'), findsOneWidget);

    await tester.tap(find.byKey(failureRetryKey));
    await tester.pumpAndSettle();
    expect(find.byKey(failureViewKey), findsNothing);
    expect(find.byKey(attendanceGridKey), findsOneWidget);
  });

  testWidgets('pull to refresh reloads the month', (tester) async {
    final repo = _FakeRepo((_) async => _november());
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(repo.calls.length, 2);
  });

  testWidgets('dark theme renders', (tester) async {
    await tester.pumpWidget(
      _app(_FakeRepo((_) async => _november()), theme: appDarkTheme),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(attendanceGridKey), findsOneWidget);
  });

  testWidgets('Nepali smoke: month names localised, digits stay ASCII', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(_FakeRepo((_) async => _november()), locale: const Locale('ne')),
    );
    await tester.pumpAndSettle();

    expect(find.text('नोभेम्बर 2026'), findsOneWidget);
    expect(find.text('उपस्थित'), findsWidgets);
    expect(find.text('अनुपस्थित'), findsWidgets);
    expect(find.text('बिदाको दिन'), findsOneWidget);
    expect(find.bySemanticsLabel('3 नोभेम्बर, उपस्थित'), findsOneWidget);
    expect(
      find.bySemanticsLabel('12 दिन उपस्थित, 3 दिन अनुपस्थित'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(attendanceSummaryKey),
        matching: find.text('12'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
