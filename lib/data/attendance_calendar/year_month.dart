/// A calendar month, used as the key of the attendance calendar provider.
/// Value equality so `family` caches one entry per month.
class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'month out of range');

  /// The month containing a plain date.
  factory YearMonth.of(DateTime date) => YearMonth(date.year, date.month);

  final int year;
  final int month;

  /// This month moved by [delta] months (negative = earlier).
  YearMonth addMonths(int delta) {
    final int index = year * 12 + (month - 1) + delta;
    return YearMonth(index ~/ 12, index % 12 + 1);
  }

  /// Number of days in the month (28..31, leap years included).
  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  /// Monday = 1 .. Sunday = 7 for the 1st of the month.
  int get firstWeekday => DateTime.utc(year, month).weekday;

  @override
  int compareTo(YearMonth other) =>
      (year * 12 + month).compareTo(other.year * 12 + other.month);

  bool operator <(YearMonth other) => compareTo(other) < 0;
  bool operator >(YearMonth other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}
