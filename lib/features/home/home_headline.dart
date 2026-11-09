// The Home headline as a pure function of the snapshot -- no widgets, no
// l10n, no clock. The screen maps [HeadlineKind] to words; this file decides
// WHICH words and WHAT number, and is unit-tested per status.
import 'package:logfitness_membership_flutter/data/attendance/membership_snapshot.dart';

enum HeadlineKind {
  /// N days left (N >= 1). Numeral + "days left".
  daysLeft,

  /// Last day: 0 days to expiry on a live plan.
  lastDay,

  /// Expired N days ago (N >= 1). Numeral + "days ago".
  expiredAgo,

  /// Expired with no usable day count (sessions used up, expired today).
  expired,

  /// Live plan without an end date (session pack, open-ended).
  activeOpen,

  frozen,

  /// Plan starts later. [Headline.startDate] carries the date when known.
  upcoming,

  none,
}

class Headline {
  const Headline(this.kind, {this.number, this.startDate});

  final HeadlineKind kind;

  /// The big numeral for [HeadlineKind.daysLeft] / [HeadlineKind.expiredAgo].
  final int? number;
  final DateTime? startDate;

  bool get isNumeric => number != null;

  @override
  bool operator ==(Object other) =>
      other is Headline &&
      other.kind == kind &&
      other.number == number &&
      other.startDate == startDate;

  @override
  int get hashCode => Object.hash(kind, number, startDate);

  @override
  String toString() => 'Headline($kind, $number, $startDate)';
}

Headline headlineFor(MembershipSnapshot s) {
  final int? days = s.daysToExpiry;
  switch (s.banner) {
    case SnapshotBanner.active:
    case SnapshotBanner.expiring:
      if (days == null) {
        return const Headline(HeadlineKind.activeOpen);
      }
      if (days <= 0) {
        // The server banner says live, but the date is today (or the plan is a
        // session pack that is nearly used up): do not print "0 days left".
        return days == 0
            ? const Headline(HeadlineKind.lastDay)
            : Headline(HeadlineKind.expiredAgo, number: -days);
      }
      return Headline(HeadlineKind.daysLeft, number: days);
    case SnapshotBanner.expired:
      if (days != null && days < 0) {
        return Headline(HeadlineKind.expiredAgo, number: -days);
      }
      return const Headline(HeadlineKind.expired);
    case SnapshotBanner.frozen:
      return const Headline(HeadlineKind.frozen);
    case SnapshotBanner.upcoming:
      return Headline(HeadlineKind.upcoming, startDate: s.startDate);
    case SnapshotBanner.none:
      return const Headline(HeadlineKind.none);
  }
}
