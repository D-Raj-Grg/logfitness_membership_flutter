// Booking state + optimistic rollback against a fake repository.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/classes/class_board_notifier.dart';
import 'package:logfitness_membership_flutter/data/classes/classes_repository.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

final DateTime _soon = DateTime.now().toUtc().add(const Duration(days: 1));

ClassSession _session(String id, {int capacity = 2, int booked = 0}) =>
    ClassSession(
      id: id,
      classId: 'c-$id',
      className: 'Yoga $id',
      startsAt: _soon,
      endsAt: _soon.add(const Duration(hours: 1)),
      capacity: capacity,
      bookedCount: booked,
    );

ClassBooking _booking(String id, String sessionId, ClassBookingStatus s) =>
    ClassBooking(
      id: id,
      sessionId: sessionId,
      status: s,
      bookedAt: _soon,
      className: 'Yoga',
      startsAt: _soon,
      endsAt: _soon.add(const Duration(hours: 1)),
    );

class FakeRepo implements ClassesRepository {
  FakeRepo({required this.sessions, required this.bookings});

  List<ClassSession> sessions;
  List<ClassBooking> bookings;
  Object? bookError;
  Object? cancelError;
  Completer<void>? gate;
  ClassBookingStatus nextStatus = ClassBookingStatus.booked;
  int bookCalls = 0;

  @override
  Future<List<ClassSession>> listUpcomingSessions({int limit = 120}) async =>
      sessions;

  @override
  Future<List<ClassBooking>> listMyBookings({int limit = 100}) async =>
      bookings;

  @override
  Future<BookResult> book(String sessionId) async {
    bookCalls++;
    await gate?.future;
    if (bookError != null) {
      throw bookError!;
    }
    final ClassSession s = sessions.firstWhere((x) => x.id == sessionId);
    bookings = <ClassBooking>[
      _booking('b-server', sessionId, nextStatus),
      ...bookings,
    ];
    if (nextStatus == ClassBookingStatus.booked) {
      sessions = <ClassSession>[
        for (final ClassSession x in sessions)
          if (x.id == sessionId) x.copyWith(bookedCount: s.bookedCount + 1) else x,
      ];
    }
    return BookResult(bookingId: 'b-server', status: nextStatus);
  }

  @override
  Future<void> cancel(String bookingId, {String? reason}) async {
    await gate?.future;
    if (cancelError != null) {
      throw cancelError!;
    }
    bookings = <ClassBooking>[
      for (final ClassBooking b in bookings)
        if (b.id == bookingId)
          b.copyWith(status: ClassBookingStatus.cancelled)
        else
          b,
    ];
  }
}

ProviderContainer _container(FakeRepo repo) {
  final ProviderContainer c = ProviderContainer(
    overrides: [
      classesRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWithValue(null),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  const refusal = AppFailure(
    FailureKind.invalid,
    'This class session has already started',
  );

  test('book: free seat becomes booked and the board settles', () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1')],
      bookings: <ClassBooking>[],
    );
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);

    final ClassBookingStatus status = await c
        .read(classBoardProvider.notifier)
        .book(c.read(classBoardProvider).value!.sessions.first);

    expect(status, ClassBookingStatus.booked);
    final ClassBoard board = c.read(classBoardProvider).value!;
    expect(board.liveBookingFor('s1')?.id, 'b-server');
    expect(board.sessions.single.bookedCount, 1);
    expect(board.busy, isEmpty);
  });

  test('book: full session becomes waitlisted (seat count untouched)', () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1', capacity: 1, booked: 1)],
      bookings: <ClassBooking>[],
    )..nextStatus = ClassBookingStatus.waitlisted;
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);

    final ClassBookingStatus status = await c
        .read(classBoardProvider.notifier)
        .book(c.read(classBoardProvider).value!.sessions.first);

    expect(status, ClassBookingStatus.waitlisted);
    final ClassBoard board = c.read(classBoardProvider).value!;
    expect(board.liveBookingFor('s1')?.status, ClassBookingStatus.waitlisted);
    expect(board.sessions.single.bookedCount, 1);
  });

  test('book: optimistic state is visible while the RPC is in flight',
      () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1')],
      bookings: <ClassBooking>[],
    )..gate = Completer<void>();
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);
    final ClassSession s = c.read(classBoardProvider).value!.sessions.first;

    final Future<ClassBookingStatus> pending = c
        .read(classBoardProvider.notifier)
        .book(s);
    await Future<void>.delayed(Duration.zero);

    final ClassBoard mid = c.read(classBoardProvider).value!;
    expect(mid.isBusy('s1'), isTrue);
    expect(mid.liveBookingFor('s1')?.status, ClassBookingStatus.booked);
    expect(mid.sessions.single.bookedCount, 1);

    repo.gate!.complete();
    await pending;
    expect(c.read(classBoardProvider).value!.isBusy('s1'), isFalse);
  });

  test('book: refusal rolls back and rethrows the RPC text', () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1', booked: 1)],
      bookings: <ClassBooking>[],
    )..bookError = refusal;
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);
    final ClassBoard before = c.read(classBoardProvider).value!;

    await expectLater(
      c.read(classBoardProvider.notifier).book(before.sessions.first),
      throwsA(
        isA<AppFailure>().having(
          (e) => e.message,
          'message',
          'This class session has already started',
        ),
      ),
    );

    final ClassBoard after = c.read(classBoardProvider).value!;
    expect(after.bookings, isEmpty);
    expect(after.sessions.single.bookedCount, 1);
    expect(after.busy, isEmpty);
  });

  test('book: a second tap while busy is ignored', () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1')],
      bookings: <ClassBooking>[],
    )..gate = Completer<void>();
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);
    final ClassSession s = c.read(classBoardProvider).value!.sessions.first;

    final Future<ClassBookingStatus> first = c
        .read(classBoardProvider.notifier)
        .book(s);
    await Future<void>.delayed(Duration.zero);
    await expectLater(
      c.read(classBoardProvider.notifier).book(s),
      throwsA(isA<StateError>()),
    );
    repo.gate!.complete();
    await first;
    expect(repo.bookCalls, 1);
  });

  test('cancel: booked frees a seat; refusal restores booking and count',
      () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1', booked: 1)],
      bookings: <ClassBooking>[
        _booking('b1', 's1', ClassBookingStatus.booked),
      ],
    )..cancelError = const AppFailure(
        FailureKind.invalid,
        'Bookings can only be cancelled at least 120 minutes before the class starts',
      );
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);
    final ClassBooking b = c.read(classBoardProvider).value!.bookings.first;

    await expectLater(
      c.read(classBoardProvider.notifier).cancel(b),
      throwsA(isA<AppFailure>()),
    );
    ClassBoard board = c.read(classBoardProvider).value!;
    expect(board.liveBookingFor('s1')?.id, 'b1');
    expect(board.sessions.single.bookedCount, 1);
    expect(board.busy, isEmpty);

    repo.cancelError = null;
    await c.read(classBoardProvider.notifier).cancel(b);
    board = c.read(classBoardProvider).value!;
    expect(board.liveBookingFor('s1'), isNull);
    expect(
      board.bookings.single.status,
      ClassBookingStatus.cancelled,
    );
  });

  test('quietReload does not clobber an in-flight optimistic write', () async {
    final FakeRepo repo = FakeRepo(
      sessions: <ClassSession>[_session('s1')],
      bookings: <ClassBooking>[],
    )..gate = Completer<void>();
    final ProviderContainer c = _container(repo);
    await c.read(classBoardProvider.future);
    final ClassSession s = c.read(classBoardProvider).value!.sessions.first;

    final Future<ClassBookingStatus> pending = c
        .read(classBoardProvider.notifier)
        .book(s);
    await Future<void>.delayed(Duration.zero);
    await c.read(classBoardProvider.notifier).quietReload();
    expect(
      c.read(classBoardProvider).value!.liveBookingFor('s1'),
      isNotNull,
    );
    repo.gate!.complete();
    await pending;
  });
}
