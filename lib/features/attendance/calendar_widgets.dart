// Plain-widget building blocks of the attendance calendar (no calendar
// package): day cell, month grid, summary card, legend, holiday sheet.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/year_month.dart';
import 'package:logfitness_membership_flutter/features/attendance/attendance_colors.dart';
import 'package:logfitness_membership_flutter/features/attendance/calendar_logic.dart';
import 'package:logfitness_membership_flutter/features/common/animated_count.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Keys the tests assert on.
const Key attendanceSummaryKey = Key('attendance-summary');
const Key attendanceGridKey = Key('attendance-grid');
const Key attendanceLegendKey = Key('attendance-legend');
const Key attendanceSkeletonKey = Key('attendance-skeleton');
const Key attendanceHolidaySheetKey = Key('attendance-holiday-sheet');

/// Month name in the app locale. Only the name: digits stay ASCII, so the year
/// and day numbers are formatted by hand, never by intl (which would switch
/// to Devanagari numerals for `ne`).
String monthName(BuildContext context, YearMonth month) => DateFormat.MMMM(
  Localizations.localeOf(context).toLanguageTag(),
).format(DateTime.utc(month.year, month.month));

String monthTitle(BuildContext context, YearMonth month) => AppLocalizations.of(
  context,
).attendanceMonthYear(monthName(context, month), '${month.year}');

/// The status as words, for semantics and the holiday sheet.
String statusLabel(AppLocalizations l10n, AttendanceDay? day) {
  final AttendanceDayStatus status = day?.status ?? AttendanceDayStatus.none;
  return switch (status) {
    AttendanceDayStatus.present => l10n.attendanceStatusPresent,
    AttendanceDayStatus.absent => l10n.attendanceStatusAbsent,
    AttendanceDayStatus.off => l10n.attendanceStatusOff,
    AttendanceDayStatus.holiday =>
      (day?.label ?? '').trim().isEmpty
          ? l10n.attendanceStatusHoliday
          : l10n.attendanceHolidayNamed(day!.label!.trim()),
    AttendanceDayStatus.none => l10n.attendanceStatusNone,
  };
}

/// The weekday header row, Monday first.
class WeekdayRow extends StatelessWidget {
  const WeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    final String tag = Localizations.localeOf(context).toLanguageTag();
    final DateFormat fmt = DateFormat.E(tag);
    final TextStyle? style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    // 2024-01-01 was a Monday.
    return ExcludeSemantics(
      child: Row(
        children: <Widget>[
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    fmt.format(DateTime.utc(2024, 1, 1 + i)),
                    style: style,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The 6 x 7 grid of days for [month].
class MonthGrid extends StatelessWidget {
  const MonthGrid({required this.month, required this.calendar, super.key});

  final YearMonth month;
  final AttendanceCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final List<List<int?>> grid = buildMonthGrid(month);
    final Map<int, AttendanceDay> byDay = indexDays(calendar, month);
    final String name = monthName(context, month);
    final DateTime today = calendar.today;

    return Column(
      key: attendanceGridKey,
      children: <Widget>[
        for (final List<int?> row in grid)
          Row(
            children: <Widget>[
              for (final int? day in row)
                Expanded(
                  child: day == null
                      ? const AspectRatio(aspectRatio: 1)
                      : DayCell(
                          day: day,
                          monthName: name,
                          data: byDay[day],
                          isToday:
                              today.year == month.year &&
                              today.month == month.month &&
                              today.day == day,
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class DayCell extends StatelessWidget {
  const DayCell({
    required this.day,
    required this.monthName,
    required this.data,
    required this.isToday,
    super.key,
  });

  final int day;
  final String monthName;
  final AttendanceDay? data;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AttendanceColors colors = AttendanceColors.of(context);
    final AttendanceDayStatus status = data?.status ?? AttendanceDayStatus.none;
    final AttendanceCellSpec spec = specFor(status);

    final Color fill = status == AttendanceDayStatus.present
        ? colors.presentFill
        : colors.absentFill;
    final Color onFill = status == AttendanceDayStatus.present
        ? colors.onPresent
        : colors.onAbsent;
    final Color numberColor = spec.filled
        ? onFill
        : spec.dimmed
        ? scheme.onSurfaceVariant.withValues(alpha: 0.75)
        : scheme.onSurface;

    final TextStyle numberStyle =
        (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
          color: numberColor,
          fontWeight: spec.dimmed ? FontWeight.w500 : FontWeight.w800,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          height: 1.1,
        );

    final Widget content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('$day', style: numberStyle),
          if (spec.icon != null)
            Icon(
              spec.icon == AttendanceGlyph.check ? Icons.check : Icons.close,
              size: 15,
              color: onFill,
            ),
          if (spec.dot != AttendanceDot.none)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: _Dot(solid: spec.dot == AttendanceDot.solid),
            ),
        ],
      ),
    );

    final bool tappable = status == AttendanceDayStatus.holiday;
    final String label = l10n.attendanceCellSemantics(
      l10n.attendanceDayMonth(day, monthName),
      statusLabel(l10n, data),
    );

    final Widget cell = Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Brand.radiusMedium + 2),
        border: isToday ? Border.all(color: scheme.onSurface, width: 2) : null,
      ),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: spec.filled ? fill : null,
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          border: spec.outlined
              ? Border.all(color: scheme.outline.withValues(alpha: 0.6))
              : null,
        ),
        child: content,
      ),
    );

    return Semantics(
      container: true,
      label: label,
      button: tappable,
      onTap: tappable ? () => _openHoliday(context, l10n) : null,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: tappable
            ? InkResponse(
                onTap: () => _openHoliday(context, l10n),
                radius: 28,
                child: cell,
              )
            : cell,
      ),
    );
  }

  void _openHoliday(BuildContext context, AppLocalizations l10n) {
    final String name = (data?.label ?? '').trim();
    showHolidaySheet(
      context,
      name: name.isEmpty ? l10n.attendanceStatusHoliday : name,
      dateText: l10n.attendanceDayMonth(day, monthName),
    );
  }
}

/// Small marker under a day number: solid = holiday, hollow = weekly day off.
class _Dot extends StatelessWidget {
  const _Dot({required this.solid, this.size = 5});

  final bool solid;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: solid ? color : null,
        border: solid ? null : Border.all(color: color, width: 1.2),
      ),
    );
  }
}

Future<void> showHolidaySheet(
  BuildContext context, {
  required String name,
  required String dateText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) {
      final ThemeData theme = Theme.of(ctx);
      final AppLocalizations l10n = AppLocalizations.of(ctx);
      return Padding(
        key: attendanceHolidaySheetKey,
        padding: const EdgeInsets.fromLTRB(
          Brand.gutter,
          0,
          Brand.gutter,
          Brand.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const _Dot(solid: true, size: 10),
                const SizedBox(width: Brand.spaceSm),
                Text(
                  l10n.attendanceStatusHoliday.toUpperCase(),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: Brand.spaceSm),
            Text(name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Brand.spaceXs),
            Text(
              dateText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
            Text(
              l10n.attendanceHolidaySheetHint,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    },
  );
}

/// "12 present / 3 absent" with animated counts.
class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.summary, super.key});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AttendanceColors colors = AttendanceColors.of(context);
    final TextStyle countStyle = theme.textTheme.displaySmall!.copyWith(
      fontSize: 36,
    );

    Widget stat({
      required int value,
      required String label,
      required Color fill,
      required Color on,
      required IconData icon,
    }) {
      return Expanded(
        child: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: on),
            ),
            const SizedBox(width: Brand.spaceSm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedCount(value: value, style: countStyle),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      container: true,
      label: l10n.attendanceSummarySemantics(summary.present, summary.absent),
      excludeSemantics: true,
      child: LogCard(
        key: attendanceSummaryKey,
        tone: LogCardTone.tonal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.attendanceSummaryTitle.toUpperCase(),
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: Brand.spaceMd),
            Row(
              children: <Widget>[
                stat(
                  value: summary.present,
                  label: l10n.attendanceStatusPresent,
                  fill: colors.presentFill,
                  on: colors.onPresent,
                  icon: Icons.check,
                ),
                stat(
                  value: summary.absent,
                  label: l10n.attendanceStatusAbsent,
                  fill: colors.absentFill,
                  on: colors.onAbsent,
                  icon: Icons.close,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Present / Absent / Day off / Holiday key.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AttendanceColors colors = AttendanceColors.of(context);
    final ColorScheme scheme = theme.colorScheme;

    Widget item(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        swatch,
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    Widget filled(Color fill, Color on, IconData icon) => Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14, color: on),
    );

    Widget outlined(bool solid) => Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
      ),
      child: _Dot(solid: solid, size: 5),
    );

    return Wrap(
      key: attendanceLegendKey,
      spacing: Brand.spaceMd,
      runSpacing: Brand.spaceSm,
      children: <Widget>[
        item(
          filled(colors.presentFill, colors.onPresent, Icons.check),
          l10n.attendanceStatusPresent,
        ),
        item(
          filled(colors.absentFill, colors.onAbsent, Icons.close),
          l10n.attendanceStatusAbsent,
        ),
        item(outlined(false), l10n.attendanceStatusOff),
        item(outlined(true), l10n.attendanceStatusHoliday),
      ],
    );
  }
}
