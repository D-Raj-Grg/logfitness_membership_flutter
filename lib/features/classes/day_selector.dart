import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_days.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// `mon..sun` key for the l10n select, from a date-only value.
String weekdayKey(DateTime date) => const <String>[
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
][date.weekday - 1];

/// Horizontal strip of the next [kClassDayCount] days. Today says "Today"
/// instead of a weekday and keeps a heavier outline; the selected day is
/// filled -- three cues (word, outline, fill), never colour alone.
class DaySelector extends StatelessWidget {
  const DaySelector({
    required this.timeZone,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String timeZone;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: l10n.classesDaySelectorLabel,
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: Brand.gutter,
            vertical: Brand.spaceSm,
          ),
          itemCount: kClassDayCount,
          separatorBuilder: (_, _) => const SizedBox(width: Brand.spaceSm),
          itemBuilder: (BuildContext context, int offset) {
            final DateTime date = orgDayDate(offset, timeZone: timeZone);
            final bool isSelected = offset == selected;
            final bool isToday = offset == 0;
            final Color fg = isSelected ? scheme.onPrimary : scheme.onSurface;
            final String top = isToday
                ? l10n.classesToday
                : l10n.classesWeekdayShort(weekdayKey(date));
            return Semantics(
              button: true,
              selected: isSelected,
              label: '$top ${date.day}',
              child: ExcludeSemantics(
                child: Material(
                  color: isSelected ? scheme.primary : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Brand.radiusMedium),
                    side: BorderSide(
                      color: isSelected
                          ? scheme.primary
                          : (isToday ? scheme.onSurface : scheme.outlineVariant),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Brand.radiusMedium),
                    onTap: () => onSelected(offset),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 60),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Brand.spaceSm + 4,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              top,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: fg,
                                fontWeight: isToday
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
