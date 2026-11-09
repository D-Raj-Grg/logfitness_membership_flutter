// Pure logic: card state machine, day grouping, capacity label, booking split.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/domain/classes/booking_partition.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_days.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/domain/classes/session_card_state.dart';

final DateTime _now = DateTime.utc(2026, 11, 9, 6);

ClassSession _s(
  String id,
  DateTime start, {
  int capacity = 20,
  int booked = 12,
}) => ClassSession(
  id: id,
  classId: 'c',
  className: 'Yoga',
  startsAt: start,
  endsAt: start.add(const Duration(hours: 1)),
  capacity: capacity,
  bookedCount: booked,
);

ClassBooking _b(
  String id,
  DateTime start,
  ClassBookingStatus st, {
  bool cancelledSession = false,
}) => ClassBooking(
  id: id,
  sessionId: 's$id',
  status: st,
  bookedAt: _now,
  className: 'Yoga',
  startsAt: start,
  endsAt: start.add(const Duration(hours: 1)),
  sessionCancelled: cancelledSession,
);

void main() {
  group('capacity', () {
    test('label is booked/capacity text', () {
      expect(capacityLabel(12, 20), '12/20');
      expect(_s('a', _now).capacityText, '12/20');
    });
    test('spots, fullness and fill', () {
      final ClassSession open = _s('a', _now);
      expect(open.spotsLeft, 8);
      expect(open.isFull, isFalse);
      expect(open.fill, closeTo(0.6, 1e-9));
      final ClassSession full = _s('b', _now, capacity: 5, booked: 7);
      expect(full.isFull, isTrue);
      expect(full.spotsLeft, 0);
      expect(full.fill, 1.0);
    });
  });

  group('sessionCardState', () {
    final DateTime future = _now.add(const Duration(hours: 5));
    final DateTime past = _now.subtract(const Duration(minutes: 5));

    SessionCardState st(
      ClassSession s, {
      ClassBooking? live,
      bool busy = false,
    }) => sessionCardState(session: s, liveBooking: live, busy: busy, now: _now);

    test('open seat -> book', () {
      expect(st(_s('a', future)), SessionCardState.book);
    });
    test('full -> join waitlist', () {
      expect(
        st(_s('a', future, capacity: 3, booked: 3)),
        SessionCardState.joinWaitlist,
      );
    });
    test('booked / waitlisted show their own state and can cancel', () {
      final ClassSession s = _s('a', future);
      expect(
        st(s, live: _b('1', future, ClassBookingStatus.booked)),
        SessionCardState.booked,
      );
      final SessionCardState w = st(
        s,
        live: _b('1', future, ClassBookingStatus.waitlisted),
      );
      expect(w, SessionCardState.waitlisted);
      expect(w.canCancel, isTrue);
      expect(w.canBook, isFalse);
    });
    test('started session with no booking is closed', () {
      expect(st(_s('a', past)), SessionCardState.closed);
    });
    test('busy wins over everything', () {
      expect(st(_s('a', future), busy: true), SessionCardState.busy);
    });
  });

  group('groupSessionsByDay', () {
    test('buckets by day offset, sorted, dropping out-of-range days', () {
      final ClassSession late = _s('late', _now.add(const Duration(hours: 3)));
      final ClassSession early = _s('early', _now.add(const Duration(hours: 1)));
      final ClassSession tomorrow = _s('tom', _now.add(const Duration(days: 1)));
      final ClassSession far = _s('far', _now.add(const Duration(days: 30)));
      final Map<ClassSession, int> offsets = <ClassSession, int>{
        late: 0,
        early: 0,
        tomorrow: 1,
        far: 30,
      };
      final Map<int, List<ClassSession>> g = groupSessionsByDay(
        offsets.keys,
        dayOf: (s) => offsets[s]!,
      );
      expect(g.keys, <int>[0, 1, 2, 3, 4, 5, 6]);
      expect(g[0]!.map((s) => s.id), <String>['early', 'late']);
      expect(g[1]!.map((s) => s.id), <String>['tom']);
      expect(g[2], isEmpty);
      expect(g.values.expand((e) => e), hasLength(3));
    });

    test('orgDayOffset: a far-future instant is days away, today is 0', () {
      final DateTime now = DateTime.now().toUtc();
      expect(orgDayOffset(now, timeZone: 'Asia/Kathmandu'), 0);
      expect(
        orgDayOffset(
          now.add(const Duration(days: 3)),
          timeZone: 'Asia/Kathmandu',
        ),
        3,
      );
    });
  });

  group('partitionBookings', () {
    test('upcoming asc, past desc; cancelled and cancelled-session go to past',
        () {
      final DateTime t1 = _now.add(const Duration(days: 1));
      final DateTime t2 = _now.add(const Duration(days: 2));
      final DateTime p1 = _now.subtract(const Duration(days: 1));
      final DateTime p2 = _now.subtract(const Duration(days: 3));
      final r = partitionBookings(<ClassBooking>[
        _b('2', t2, ClassBookingStatus.waitlisted),
        _b('1', t1, ClassBookingStatus.booked),
        _b('x', t1, ClassBookingStatus.cancelled),
        _b('g', t2, ClassBookingStatus.booked, cancelledSession: true),
        _b('p2', p2, ClassBookingStatus.attended),
        _b('p1', p1, ClassBookingStatus.noShow),
      ], _now);
      expect(r.upcoming.map((b) => b.id), <String>['1', '2']);
      expect(r.past.map((b) => b.id), <String>['g', 'x', 'p1', 'p2']);
    });
  });

  test('ClassBookingStatus round-trips the db values', () {
    expect(ClassBookingStatus.fromDb('no_show'), ClassBookingStatus.noShow);
    expect(ClassBookingStatus.booked.isLive, isTrue);
    expect(ClassBookingStatus.cancelled.isLive, isFalse);
    expect(() => ClassBookingStatus.fromDb('nope'), throwsFormatException);
  });
}
