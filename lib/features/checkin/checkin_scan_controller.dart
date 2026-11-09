// The scan state machine, free of Flutter widgets and of the camera.
//
//   scanning --(valid LG1 code)--> submitting --(answer)--> result --(reset)--> scanning
//
// Rules it enforces:
//  * Single shot: after the first valid code, further frames are ignored until
//    [reset]. The camera firing ten times a second cannot cause ten RPCs.
//  * Foreign QRs (anything not `LG1.<id>.<8 digits>`) are ignored silently;
//    only after [foreignHintAfter] of seeing *only* foreign codes does
//    [foreignHint] flip on, so the screen can offer a gentle nudge.
//  * A code the server called stale is not re-sent: scanning it again would
//    just burn the member's bad-code allowance. A *different* code is fine.
//  * A successful answer returns to scanning by itself after [autoReturn].
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:logfitness_membership_flutter/data/door/door_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';

enum ScanPhase { scanning, submitting, result }

class CheckInScanController extends ChangeNotifier {
  CheckInScanController({
    required DoorRepository repository,
    DateTime Function()? now,
    this.autoReturn = const Duration(seconds: 6),
    this.foreignHintAfter = const Duration(seconds: 8),
    this.sameCodeCooldown = const Duration(seconds: 3),
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  final DoorRepository _repository;
  final DateTime Function() _now;
  final Duration autoReturn;
  final Duration foreignHintAfter;
  final Duration sameCodeCooldown;

  ScanPhase _phase = ScanPhase.scanning;
  DoorCheckInResult? _result;
  AppFailure? _failure;
  bool _foreignHint = false;
  bool _active = false;
  bool _disposed = false;

  Timer? _autoReturnTimer;
  Timer? _foreignTimer;

  // Last payload we submitted, for the same-code guard.
  String? _lastSubmitted;
  DateTime? _lastSubmittedAt;
  String? _staleCode;

  ScanPhase get phase => _phase;

  /// The server's answer; set while [phase] is [ScanPhase.result] unless the
  /// call itself failed (then [failure] is set instead).
  DoorCheckInResult? get result => _result;
  AppFailure? get failure => _failure;
  bool get foreignHint => _foreignHint;

  /// Whether the camera should be looked at right now (tab visible, app in
  /// the foreground). Codes arriving while inactive are dropped.
  bool get active => _active;

  void setActive(bool value) {
    if (_active == value) return;
    _active = value;
    if (!value) {
      _foreignTimer?.cancel();
      _foreignTimer = null;
      _foreignHint = false;
      // Leaving mid-result: come back to a fresh scanner, not a stale verdict.
      if (_phase == ScanPhase.result) {
        _toScanning(clearCooldown: false);
        return;
      }
      notifyListeners();
    }
  }

  /// Feed every batch of raw QR texts the camera reports.
  void onCodes(List<String> rawCodes) {
    if (_disposed || !_active || _phase != ScanPhase.scanning) return;

    DoorQrPayload? valid;
    bool sawForeign = false;
    for (final String raw in rawCodes) {
      final DoorQrPayload? p = DoorQrPayload.tryParse(raw);
      if (p != null) {
        valid = p;
        break;
      }
      sawForeign = true;
    }

    if (valid == null) {
      if (sawForeign) _armForeignHint();
      return;
    }
    final DoorQrPayload payload = valid;
    if (payload.text == _staleCode) return;
    if (payload.text == _lastSubmitted &&
        _lastSubmittedAt != null &&
        _now().difference(_lastSubmittedAt!) < sameCodeCooldown) {
      return;
    }
    unawaited(_submit(payload));
  }

  void _armForeignHint() {
    if (_foreignHint || _foreignTimer != null) return;
    _foreignTimer = Timer(foreignHintAfter, () {
      _foreignTimer = null;
      if (_disposed || _phase != ScanPhase.scanning || !_active) return;
      _foreignHint = true;
      notifyListeners();
    });
  }

  Future<void> _submit(DoorQrPayload payload) async {
    _foreignTimer?.cancel();
    _foreignTimer = null;
    _foreignHint = false;
    _phase = ScanPhase.submitting;
    _result = null;
    _failure = null;
    _lastSubmitted = payload.text;
    _lastSubmittedAt = _now();
    notifyListeners();

    DoorCheckInResult? answer;
    AppFailure? failed;
    try {
      answer = await _repository.checkIn(payload);
    } on AppFailure catch (e) {
      failed = e;
    } catch (e) {
      failed = AppFailure(FailureKind.unknown, e.toString(), cause: e);
    }
    if (_disposed) return;
    // Backgrounded while the call was in flight: keep the verdict anyway. The
    // door may well have opened; the member should see why when they return.

    _result = answer;
    _failure = failed;
    _phase = ScanPhase.result;
    _lastSubmittedAt = _now();
    if (answer is DoorInvalidCode) {
      _staleCode = payload.text;
    }
    if (failed != null) {
      // Nothing reached the server's verdict: let the same code be retried.
      _lastSubmitted = null;
    }
    notifyListeners();

    if (answer is DoorOk) {
      _autoReturnTimer?.cancel();
      _autoReturnTimer = Timer(autoReturn, reset);
    }
  }

  /// Back to the scanner (tap on the result, "Scan again", or the timer).
  void reset() {
    if (_disposed || _phase == ScanPhase.scanning) return;
    _toScanning(clearCooldown: false);
  }

  void _toScanning({required bool clearCooldown}) {
    _autoReturnTimer?.cancel();
    _autoReturnTimer = null;
    _phase = ScanPhase.scanning;
    _result = null;
    _failure = null;
    if (clearCooldown) {
      _lastSubmitted = null;
      _lastSubmittedAt = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _autoReturnTimer?.cancel();
    _foreignTimer?.cancel();
    super.dispose();
  }
}
