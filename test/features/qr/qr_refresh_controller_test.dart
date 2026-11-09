import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/qr/qr_token.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/qr/qr_refresh_controller.dart';

/// A manual clock plus timers that only fire when the test advances time.
class FakeTime {
  DateTime now = DateTime.utc(2026, 11, 9, 12);
  final List<_FakeTimer> _timers = <_FakeTimer>[];

  Timer create(Duration delay, void Function() cb) {
    final _FakeTimer t = _FakeTimer(now.add(delay), cb);
    _timers.add(t);
    return t;
  }

  int get pending => _timers.where((t) => t.isActive).length;

  /// Advances the clock, firing due timers in order and letting the async
  /// mints they start settle.
  Future<void> advance(Duration d) async {
    final DateTime target = now.add(d);
    while (true) {
      final List<_FakeTimer> due =
          _timers.where((t) => t.isActive && !t.at.isAfter(target)).toList()
            ..sort((a, b) => a.at.compareTo(b.at));
      if (due.isEmpty) break;
      final _FakeTimer next = due.first;
      now = next.at;
      next.fire();
      await _settle();
    }
    now = target;
  }
}

Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeTimer implements Timer {
  _FakeTimer(this.at, this._cb);

  final DateTime at;
  final void Function() _cb;
  bool _active = true;

  void fire() {
    _active = false;
    _cb();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

class _Harness {
  _Harness({this.ttl = const Duration(seconds: 90)}) {
    controller = QrRefreshController(
      mint: _mint,
      clock: () => time.now,
      timerFactory: time.create,
    );
  }

  final Duration ttl;
  final FakeTime time = FakeTime();
  late final QrRefreshController controller;
  int mints = 0;

  /// Queue of outcomes; an `AppFailure`/error is thrown, otherwise succeed.
  final List<Object> script = <Object>[];

  Future<QrToken> _mint() async {
    mints++;
    if (script.isNotEmpty) {
      final Object next = script.removeAt(0);
      // ignore: only_throw_errors
      throw next;
    }
    return QrToken(token: 'tok-$mints', ttl: ttl);
  }
}

void main() {
  test('first mint publishes a lease and schedules at ttl - 20 s', () async {
    final _Harness h = _Harness();
    await h.controller.resume();

    expect(h.mints, 1);
    expect(h.controller.lease?.token.token, 'tok-1');
    expect(h.controller.remaining(), const Duration(seconds: 90));
    expect(h.time.pending, 1);

    await h.time.advance(const Duration(seconds: 69));
    expect(h.mints, 1, reason: '69 s < 70 s');
    await h.time.advance(const Duration(seconds: 1));
    expect(h.mints, 2, reason: 're-mint at 70 s = ttl - 20 s');
    expect(h.controller.lease?.token.token, 'tok-2');
    h.controller.dispose();
  });

  test('expiry is measured from local receipt, not a server timestamp', () async {
    final _Harness h = _Harness();
    await h.controller.resume();
    expect(h.controller.lease!.receivedAt, h.time.now);
    expect(
      h.controller.lease!.expiresAt,
      h.time.now.add(const Duration(seconds: 90)),
    );
    h.controller.dispose();
  });

  test('a short ttl refreshes at 60 % of its life, not in a hot loop', () async {
    final _Harness h = _Harness(ttl: const Duration(seconds: 10));
    await h.controller.resume();
    await h.time.advance(const Duration(seconds: 5));
    expect(h.mints, 1);
    await h.time.advance(const Duration(seconds: 1));
    expect(h.mints, 2);
    h.controller.dispose();
  });

  test('resume re-mints when under 20 s remain', () async {
    final _Harness h = _Harness();
    await h.controller.resume();
    h.controller.pause();
    expect(h.time.pending, 0, reason: 'pause stops the timer');

    h.time.now = h.time.now.add(const Duration(seconds: 75)); // 15 s left
    await h.controller.resume();
    expect(h.mints, 2);
    expect(h.controller.lease?.token.token, 'tok-2');
    h.controller.dispose();
  });

  test('resume with plenty of life left keeps the token and reschedules', () async {
    final _Harness h = _Harness();
    await h.controller.resume();
    h.controller.pause();

    h.time.now = h.time.now.add(const Duration(seconds: 30)); // 60 s left
    await h.controller.resume();
    expect(h.mints, 1);
    expect(h.time.pending, 1);

    await h.time.advance(const Duration(seconds: 40)); // 10 s past the margin
    expect(h.mints, 2);
    h.controller.dispose();
  });

  test('resume after the token fully expired re-mints', () async {
    final _Harness h = _Harness();
    await h.controller.resume();
    h.controller.pause();
    h.time.now = h.time.now.add(const Duration(minutes: 10));
    expect(h.controller.hasLiveToken, isFalse);
    await h.controller.resume();
    expect(h.mints, 2);
    expect(h.controller.hasLiveToken, isTrue);
    h.controller.dispose();
  });

  test('a transient failure retries every 10 s until it works', () async {
    final _Harness h = _Harness();
    h.script.addAll(<Object>[
      const AppFailure(FailureKind.offline, 'No connection'),
      const AppFailure(FailureKind.offline, 'No connection'),
    ]);
    await h.controller.resume();

    expect(h.controller.isReconnecting, isTrue);
    expect(h.controller.ineligible, isFalse);
    expect(h.controller.lease, isNull);

    await h.time.advance(const Duration(seconds: 9));
    expect(h.mints, 1);
    await h.time.advance(const Duration(seconds: 1));
    expect(h.mints, 2);
    expect(h.controller.isReconnecting, isTrue);

    await h.time.advance(const Duration(seconds: 10));
    expect(h.mints, 3);
    expect(h.controller.isReconnecting, isFalse);
    expect(h.controller.lease?.token.token, 'tok-3');
    h.controller.dispose();
  });

  test('a failed refresh keeps the still-valid token while retrying', () async {
    final _Harness h = _Harness();
    await h.controller.resume();
    h.script.add(const AppFailure(FailureKind.offline, 'No connection'));

    await h.time.advance(const Duration(seconds: 70));
    expect(h.mints, 2);
    expect(h.controller.isReconnecting, isTrue);
    expect(h.controller.hasLiveToken, isTrue, reason: '20 s of life left');

    await h.time.advance(const Duration(seconds: 10));
    expect(h.mints, 3);
    expect(h.controller.isReconnecting, isFalse);
    h.controller.dispose();
  });

  test('a refusal is not retried automatically and drops the token', () async {
    final _Harness h = _Harness();
    h.script.add(
      const AppFailure(FailureKind.refused, 'Your membership has expired.'),
    );
    await h.controller.resume();

    expect(h.controller.ineligible, isTrue);
    expect(h.controller.isReconnecting, isFalse);
    expect(h.controller.failure?.message, 'Your membership has expired.');
    expect(h.controller.lease, isNull);
    expect(h.time.pending, 0);

    await h.time.advance(const Duration(minutes: 5));
    expect(h.mints, 1);

    // The manual retry works and clears the state.
    await h.controller.mint();
    expect(h.mints, 2);
    expect(h.controller.ineligible, isFalse);
    expect(h.controller.lease, isNotNull);
    h.controller.dispose();
  });

  test('no refresh fires after dispose', () async {
    final _Harness h = _Harness();
    await h.controller.resume();
    h.controller.dispose();
    expect(h.time.pending, 0);

    await h.time.advance(const Duration(minutes: 5));
    expect(h.mints, 1);
  });

  test('a mint that finishes after dispose schedules nothing', () async {
    final Completer<QrToken> gate = Completer<QrToken>();
    final FakeTime time = FakeTime();
    final QrRefreshController c = QrRefreshController(
      mint: () => gate.future,
      clock: () => time.now,
      timerFactory: time.create,
    );
    final Future<void> pending = c.resume();
    c.dispose();
    gate.complete(const QrToken(token: 'late', ttl: Duration(seconds: 90)));
    await pending;
    expect(time.pending, 0);
  });

  test('pause stops retries; resume restarts them', () async {
    final _Harness h = _Harness();
    h.script.add(const AppFailure(FailureKind.offline, 'No connection'));
    await h.controller.resume();
    h.controller.pause();
    await h.time.advance(const Duration(minutes: 1));
    expect(h.mints, 1);

    await h.controller.resume();
    expect(h.mints, 2);
    expect(h.controller.lease, isNotNull);
    h.controller.dispose();
  });

  test('overlapping mints are collapsed', () async {
    final _Harness h = _Harness();
    final Future<void> a = h.controller.mint();
    final Future<void> b = h.controller.mint();
    await Future.wait(<Future<void>>[a, b]);
    expect(h.mints, 1);
    h.controller.dispose();
  });
}
