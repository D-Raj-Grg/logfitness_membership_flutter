import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/attendance/membership_snapshot.dart';
import 'package:logfitness_membership_flutter/features/home/home_headline.dart';

MembershipSnapshot _snap(
  SnapshotBanner banner, {
  int? days,
  DateTime? start,
}) => MembershipSnapshot(banner: banner, daysToExpiry: days, startDate: start);

void main() {
  group('headlineFor', () {
    test('active with days left', () {
      expect(
        headlineFor(_snap(SnapshotBanner.active, days: 30)),
        const Headline(HeadlineKind.daysLeft, number: 30),
      );
    });

    test('expiring is still a days-left headline', () {
      expect(
        headlineFor(_snap(SnapshotBanner.expiring, days: 3)),
        const Headline(HeadlineKind.daysLeft, number: 3),
      );
    });

    test('1 day keeps the numeral 1 (singular is the label\'s job)', () {
      final Headline h = headlineFor(_snap(SnapshotBanner.expiring, days: 1));
      expect(h.kind, HeadlineKind.daysLeft);
      expect(h.number, 1);
    });

    test('boundary 0 days is the last day, not "0 days left"', () {
      expect(
        headlineFor(_snap(SnapshotBanner.expiring, days: 0)).kind,
        HeadlineKind.lastDay,
      );
      expect(
        headlineFor(_snap(SnapshotBanner.active, days: 0)).number,
        isNull,
      );
    });

    test('expired N days ago', () {
      expect(
        headlineFor(_snap(SnapshotBanner.expired, days: -12)),
        const Headline(HeadlineKind.expiredAgo, number: 12),
      );
      expect(
        headlineFor(_snap(SnapshotBanner.expired, days: -1)).number,
        1,
      );
    });

    test('expired without a past date (sessions used up) has no count', () {
      expect(
        headlineFor(_snap(SnapshotBanner.expired, days: 20)).kind,
        HeadlineKind.expired,
      );
      expect(
        headlineFor(_snap(SnapshotBanner.expired)).kind,
        HeadlineKind.expired,
      );
      expect(
        headlineFor(_snap(SnapshotBanner.expired, days: 0)).kind,
        HeadlineKind.expired,
      );
    });

    test('live banner but past date never shows negative days left', () {
      expect(
        headlineFor(_snap(SnapshotBanner.active, days: -2)),
        const Headline(HeadlineKind.expiredAgo, number: 2),
      );
    });

    test('active with no end date', () {
      expect(
        headlineFor(_snap(SnapshotBanner.active)).kind,
        HeadlineKind.activeOpen,
      );
    });

    test('frozen ignores the day count', () {
      expect(
        headlineFor(_snap(SnapshotBanner.frozen, days: 40)).kind,
        HeadlineKind.frozen,
      );
    });

    test('upcoming carries the start date when known', () {
      final DateTime start = DateTime.utc(2026, 12, 1);
      expect(
        headlineFor(_snap(SnapshotBanner.upcoming, days: 60, start: start)),
        Headline(HeadlineKind.upcoming, startDate: start),
      );
      expect(
        headlineFor(_snap(SnapshotBanner.upcoming)).startDate,
        isNull,
      );
    });

    test('none', () {
      expect(
        headlineFor(const MembershipSnapshot.empty()).kind,
        HeadlineKind.none,
      );
    });
  });

  group('MembershipSnapshot.fromRow', () {
    test('maps the attendance_snapshot columns', () {
      final MembershipSnapshot s = MembershipSnapshot.fromRow(<String, dynamic>{
        'membership_id': 'abc',
        'membership_status': 'active',
        'plan_name': 'Monthly',
        'days_to_expiry': 5,
        'sessions_remaining': null,
        'due_paisa': 150000,
        'banner': 'expiring',
      });
      expect(s.banner, SnapshotBanner.expiring);
      expect(s.planName, 'Monthly');
      expect(s.daysToExpiry, 5);
      expect(s.sessionsRemaining, isNull);
      expect(s.duePaisa, 150000);
    });

    test('unknown or left banner falls to none', () {
      expect(SnapshotBanner.parse('left'), SnapshotBanner.none);
      expect(SnapshotBanner.parse('something-new'), SnapshotBanner.none);
      expect(SnapshotBanner.parse(null), SnapshotBanner.none);
    });
  });
}
