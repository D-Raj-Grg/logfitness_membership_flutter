// Pure day logic for the Classes tab. A "day" is an offset from the org's
// today (0 = today), computed in the org's timezone -- never the phone's.
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';

/// How many days the selector offers, today included.
const int kClassDayCount = 7;

/// Org-calendar day offset of [instant] from the org's today.
int orgDayOffset(DateTime instant, {required String timeZone}) =>
    daysUntil(instant, timeZone: timeZone);

/// Buckets [sessions] by day offset, each bucket sorted by start time.
/// Offsets outside `0..days-1` are dropped. Every offset has a (possibly
/// empty) bucket so the selector never has to null-check.
Map<int, List<ClassSession>> groupSessionsByDay(
  Iterable<ClassSession> sessions, {
  required int Function(ClassSession) dayOf,
  int days = kClassDayCount,
}) {
  final Map<int, List<ClassSession>> out = <int, List<ClassSession>>{
    for (int i = 0; i < days; i++) i: <ClassSession>[],
  };
  for (final ClassSession s in sessions) {
    out[dayOf(s)]?.add(s);
  }
  for (final List<ClassSession> bucket in out.values) {
    bucket.sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }
  return out;
}

/// The calendar date (UTC-pinned, date-only) [offset] days after the org's
/// today. Used for the weekday letters and day numbers in the selector.
DateTime orgDayDate(int offset, {required String timeZone}) =>
    todayInOrgTimezone(timeZone: timeZone).add(Duration(days: offset));
