import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/door/door_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/checkin/checkin_scan_controller.dart';

const String _code = 'LG1.7.56789012';
const String _code2 = 'LG1.7.11111111';

class FakeDoorRepository implements DoorRepository {
  final List<Object> script = <Object>[];
  final List<String> calls = <String>[];
  Completer<void>? gate;

  @override
  Future<DoorCheckInResult> checkIn(DoorQrPayload payload) async {
    calls.add(payload.text);
    if (gate != null) await gate!.future;
    if (script.isEmpty) return const DoorOk(memberName: 'Sita Rai');
    final Object next = script.removeAt(0);
    if (next is DoorCheckInResult) return next;
    // ignore: only_throw_errors
    throw next;
  }
}

CheckInScanController _make(
  FakeDoorRepository repo, {
  DateTime Function()? now,
}) {
  return CheckInScanController(repository: repo, now: now)..setActive(true);
}

void main() {
  test(
    'a valid code is submitted once, then ignored while a verdict shows',
    () async {
      final repo = FakeDoorRepository();
      final c = _make(repo);

      c.onCodes(<String>[_code]);
      c.onCodes(<String>[_code]);
      c.onCodes(<String>[_code2]);
      expect(c.phase, ScanPhase.submitting);
      await pumpEventQueue();

      expect(repo.calls, <String>[_code]);
      expect(c.phase, ScanPhase.result);
      expect(c.result, isA<DoorOk>());

      // Frames keep arriving behind the verdict: nothing happens.
      c.onCodes(<String>[_code2]);
      await pumpEventQueue();
      expect(repo.calls, hasLength(1));
      c.dispose();
    },
  );

  test('foreign QRs are ignored and never reach the repository', () async {
    final repo = FakeDoorRepository();
    final c = _make(repo);
    c.onCodes(<String>['https://example.com', 'WIFI:S:x;;', 'LG2.7.56789012']);
    await pumpEventQueue();
    expect(repo.calls, isEmpty);
    expect(c.phase, ScanPhase.scanning);
    c.dispose();
  });

  test('a valid code among foreign ones in the same frame is used', () async {
    final repo = FakeDoorRepository();
    final c = _make(repo);
    c.onCodes(<String>['https://example.com', ' $_code ']);
    await pumpEventQueue();
    expect(repo.calls, <String>[_code]);
    c.dispose();
  });

  test('inactive controller drops codes', () async {
    final repo = FakeDoorRepository();
    final c = CheckInScanController(repository: repo); // not active
    c.onCodes(<String>[_code]);
    await pumpEventQueue();
    expect(repo.calls, isEmpty);
    c.dispose();
  });

  testWidgets('foreign hint appears after 8 s of only foreign codes', (
    tester,
  ) async {
    final c = _make(FakeDoorRepository());
    c.onCodes(<String>['https://example.com']);
    await tester.pump(const Duration(seconds: 7));
    expect(c.foreignHint, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(c.foreignHint, isTrue);
    c.dispose();
  });

  testWidgets('a valid code cancels the pending foreign hint', (tester) async {
    final c = _make(FakeDoorRepository());
    c.onCodes(<String>['https://example.com']);
    await tester.pump(const Duration(seconds: 3));
    c.onCodes(<String>[_code]);
    await tester.pump(const Duration(seconds: 1));
    expect(c.phase, ScanPhase.result);
    c.reset();
    await tester.pump(const Duration(seconds: 10));
    expect(c.foreignHint, isFalse);
    c.dispose();
  });

  testWidgets('ok auto-returns to scanning after 6 s', (tester) async {
    final c = _make(FakeDoorRepository());
    c.onCodes(<String>[_code]);
    await tester.pump(const Duration(milliseconds: 1));
    expect(c.phase, ScanPhase.result);
    await tester.pump(const Duration(seconds: 5));
    expect(c.phase, ScanPhase.result);
    await tester.pump(const Duration(seconds: 2));
    expect(c.phase, ScanPhase.scanning);
    c.dispose();
  });

  test('denied does not auto-return; reset does', () async {
    final repo = FakeDoorRepository()
      ..script.add(const DoorDenied(reason: DoorDeniedReason.expired));
    final c = _make(repo);
    c.onCodes(<String>[_code]);
    await pumpEventQueue();
    expect(c.result, isA<DoorDenied>());
    expect(c.phase, ScanPhase.result);
    c.reset();
    expect(c.phase, ScanPhase.scanning);
    expect(c.result, isNull);
    c.dispose();
  });

  test('closed and rate_limited surface as results', () async {
    for (final DoorCheckInResult r in <DoorCheckInResult>[
      const DoorClosed(),
      const DoorRateLimited(),
    ]) {
      final repo = FakeDoorRepository()..script.add(r);
      final c = _make(repo);
      c.onCodes(<String>[_code]);
      await pumpEventQueue();
      expect(c.result.runtimeType, r.runtimeType);
      c.dispose();
    }
  });

  test(
    'invalid_code: the same stale code is never re-sent, a new one is',
    () async {
      final repo = FakeDoorRepository()..script.add(const DoorInvalidCode());
      var t = DateTime(2026, 1, 1);
      final c = _make(repo, now: () => t);
      c.onCodes(<String>[_code]);
      await pumpEventQueue();
      expect(c.result, isA<DoorInvalidCode>());
      c.reset();

      t = t.add(const Duration(minutes: 5));
      c.onCodes(<String>[_code]);
      await pumpEventQueue();
      expect(repo.calls, <String>[_code]);

      c.onCodes(<String>[_code2]);
      await pumpEventQueue();
      expect(repo.calls, <String>[_code, _code2]);
      c.dispose();
    },
  );

  test('same code right after a verdict is debounced for 3 s', () async {
    final repo = FakeDoorRepository()
      ..script.add(const DoorClosed())
      ..script.add(const DoorClosed());
    var t = DateTime(2026, 1, 1);
    final c = _make(repo, now: () => t);
    c.onCodes(<String>[_code]);
    await pumpEventQueue();
    c.reset();

    t = t.add(const Duration(seconds: 1));
    c.onCodes(<String>[_code]);
    await pumpEventQueue();
    expect(repo.calls, hasLength(1));

    t = t.add(const Duration(seconds: 3));
    c.onCodes(<String>[_code]);
    await pumpEventQueue();
    expect(repo.calls, hasLength(2));
    c.dispose();
  });

  test(
    'offline: failure is kept, and the same code may be retried at once',
    () async {
      final repo = FakeDoorRepository()
        ..script.add(const AppFailure(FailureKind.offline, 'No connection'));
      final c = _make(repo);
      c.onCodes(<String>[_code]);
      await pumpEventQueue();
      expect(c.phase, ScanPhase.result);
      expect(c.result, isNull);
      expect(c.failure?.kind, FailureKind.offline);

      c.reset();
      c.onCodes(<String>[_code]);
      await pumpEventQueue();
      expect(repo.calls, <String>[_code, _code]);
      expect(c.result, isA<DoorOk>());
      c.dispose();
    },
  );

  test('an unexpected exception becomes an unknown failure', () async {
    final repo = FakeDoorRepository()..script.add(StateError('boom'));
    final c = _make(repo);
    c.onCodes(<String>[_code]);
    await pumpEventQueue();
    expect(c.failure?.kind, FailureKind.unknown);
    c.dispose();
  });

  test(
    'going inactive while a verdict shows returns to a fresh scanner',
    () async {
      final repo = FakeDoorRepository();
      final c = _make(repo);
      c.onCodes(<String>[_code]);
      await pumpEventQueue();
      expect(c.phase, ScanPhase.result);
      c.setActive(false);
      expect(c.phase, ScanPhase.scanning);
      c.dispose();
    },
  );

  test('disposing mid-flight does not throw', () async {
    final repo = FakeDoorRepository()..gate = Completer<void>();
    final c = _make(repo);
    c.onCodes(<String>[_code]);
    c.dispose();
    repo.gate!.complete();
    await pumpEventQueue();
  });
}
