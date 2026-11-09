// Shared state behind the Classes and Bookings screens, so a booking made on
// one is immediately visible on the other.
//
// Booking and cancelling are optimistic: the UI changes first, the RPC runs,
// and on failure only the rows this action touched are restored and the
// (already mapped) AppFailure is rethrown for the screen to show. After a
// success the board is re-read quietly so server truth (seat counts, waitlist
// promotion) replaces the guess.
//
// Realtime vs polling: polling (see `classes_screen.dart`), decided in
// TASKS.md Phase 6.
//
// Plain (non-annotated) Riverpod on purpose: no codegen needed.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/data/classes/classes_repository.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

class ClassBoard {
  const ClassBoard({
    required this.sessions,
    required this.bookings,
    this.busy = const <String>{},
  });

  final List<ClassSession> sessions;
  final List<ClassBooking> bookings;

  /// Session ids and booking ids with a write in flight.
  final Set<String> busy;

  /// The caller's live (booked/waitlisted) booking on [sessionId], if any.
  ClassBooking? liveBookingFor(String sessionId) {
    for (final ClassBooking b in bookings) {
      if (b.sessionId == sessionId && b.status.isLive) {
        return b;
      }
    }
    return null;
  }

  bool isBusy(String sessionId) {
    if (busy.contains(sessionId)) {
      return true;
    }
    final ClassBooking? live = liveBookingFor(sessionId);
    return live != null && busy.contains(live.id);
  }

  ClassBoard copyWith({
    List<ClassSession>? sessions,
    List<ClassBooking>? bookings,
    Set<String>? busy,
  }) => ClassBoard(
    sessions: sessions ?? this.sessions,
    bookings: bookings ?? this.bookings,
    busy: busy ?? this.busy,
  );
}

class ClassBoardNotifier extends AsyncNotifier<ClassBoard> {
  ClassesRepository get _repo => ref.read(classesRepositoryProvider);

  @override
  Future<ClassBoard> build() {
    // A different member signing in must never see the last one's bookings.
    ref.watch(sessionProvider.select((s) => s?.user.id));
    return _load();
  }

  Future<ClassBoard> _load() async {
    final List<Object> results = await Future.wait<Object>(<Future<Object>>[
      _repo.listUpcomingSessions(),
      _repo.listMyBookings(),
    ]);
    return ClassBoard(
      sessions: results[0] as List<ClassSession>,
      bookings: results[1] as List<ClassBooking>,
    );
  }

  /// Pull-to-refresh: re-read, keep the old data on screen while loading.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  /// Poll tick / after a write: re-read without a spinner; keeps current data
  /// if it fails or if a write is in flight (its optimistic state wins until
  /// it settles).
  Future<void> quietReload() async {
    final ClassBoard? before = state.value;
    if (before != null && before.busy.isNotEmpty) {
      return;
    }
    try {
      final ClassBoard fresh = await _load();
      final ClassBoard? current = state.value;
      if (current != null && current.busy.isNotEmpty) {
        return;
      }
      state = AsyncData<ClassBoard>(fresh);
    } catch (_) {
      // Optimistic/last-known state stays; the next tick or pull corrects it.
    }
  }

  void _setBusy(String id, {required bool on}) {
    final ClassBoard? current = state.value;
    if (current == null) {
      return;
    }
    final Set<String> next = <String>{...current.busy};
    on ? next.add(id) : next.remove(id);
    state = AsyncData<ClassBoard>(current.copyWith(busy: next));
  }

  /// Books (or waitlists) [session]. Returns the status the server gave.
  /// Throws an `AppFailure` after rolling back.
  Future<ClassBookingStatus> book(ClassSession session) async {
    final ClassBoard? before = state.value;
    if (before == null || before.isBusy(session.id)) {
      throw StateError('Board not ready');
    }
    final bool willWait = session.isFull;
    final String pendingId = 'pending-${session.id}';
    final ClassBooking optimistic = ClassBooking(
      id: pendingId,
      sessionId: session.id,
      status: willWait
          ? ClassBookingStatus.waitlisted
          : ClassBookingStatus.booked,
      bookedAt: DateTime.now().toUtc(),
      className: session.className,
      room: session.room,
      startsAt: session.startsAt,
      endsAt: session.endsAt,
    );
    state = AsyncData<ClassBoard>(
      before.copyWith(
        bookings: <ClassBooking>[optimistic, ...before.bookings],
        sessions: <ClassSession>[
          for (final ClassSession s in before.sessions)
            if (s.id == session.id && !willWait)
              s.copyWith(bookedCount: s.bookedCount + 1)
            else
              s,
        ],
        busy: <String>{...before.busy, session.id},
      ),
    );
    try {
      final BookResult result = await _repo.book(session.id);
      // Swap the guess for the server's id and status straight away, so the
      // booking is cancellable even if the quiet re-read below fails.
      final ClassBoard? settled = state.value;
      if (settled != null) {
        state = AsyncData<ClassBoard>(
          settled.copyWith(
            bookings: <ClassBooking>[
              for (final ClassBooking b in settled.bookings)
                if (b.id == pendingId)
                  ClassBooking(
                    id: result.bookingId,
                    sessionId: b.sessionId,
                    status: result.status,
                    bookedAt: b.bookedAt,
                    className: b.className,
                    room: b.room,
                    startsAt: b.startsAt,
                    endsAt: b.endsAt,
                  )
                else
                  b,
            ],
          ),
        );
      }
      _setBusy(session.id, on: false);
      await quietReload();
      return result.status;
    } catch (_) {
      final ClassBoard? now = state.value;
      if (now != null) {
        state = AsyncData<ClassBoard>(
          now.copyWith(
            bookings: <ClassBooking>[
              for (final ClassBooking b in now.bookings)
                if (b.id != pendingId) b,
            ],
            sessions: <ClassSession>[
              for (final ClassSession s in now.sessions)
                if (s.id == session.id) session else s,
            ],
            busy: <String>{...now.busy}..remove(session.id),
          ),
        );
      }
      rethrow;
    }
  }

  /// Cancels [booking]. Throws an `AppFailure` after rolling back.
  Future<void> cancel(ClassBooking booking) async {
    final ClassBoard? before = state.value;
    if (before == null || before.busy.contains(booking.id)) {
      throw StateError('Board not ready');
    }
    final bool freedSeat = booking.status == ClassBookingStatus.booked;
    state = AsyncData<ClassBoard>(
      before.copyWith(
        bookings: <ClassBooking>[
          for (final ClassBooking b in before.bookings)
            if (b.id == booking.id)
              b.copyWith(status: ClassBookingStatus.cancelled)
            else
              b,
        ],
        sessions: <ClassSession>[
          for (final ClassSession s in before.sessions)
            if (s.id == booking.sessionId && freedSeat && s.bookedCount > 0)
              s.copyWith(bookedCount: s.bookedCount - 1)
            else
              s,
        ],
        busy: <String>{...before.busy, booking.id},
      ),
    );
    try {
      await _repo.cancel(booking.id);
      _setBusy(booking.id, on: false);
      await quietReload();
    } catch (_) {
      final ClassBoard? now = state.value;
      if (now != null) {
        final ClassSession? originalSession = before.sessions
            .where((s) => s.id == booking.sessionId)
            .firstOrNull;
        state = AsyncData<ClassBoard>(
          now.copyWith(
            bookings: <ClassBooking>[
              for (final ClassBooking b in now.bookings)
                if (b.id == booking.id) booking else b,
            ],
            sessions: <ClassSession>[
              for (final ClassSession s in now.sessions)
                if (s.id == booking.sessionId && originalSession != null)
                  originalSession
                else
                  s,
            ],
            busy: <String>{...now.busy}..remove(booking.id),
          ),
        );
      }
      rethrow;
    }
  }
}

final classBoardProvider =
    AsyncNotifierProvider<ClassBoardNotifier, ClassBoard>(
      ClassBoardNotifier.new,
    );
