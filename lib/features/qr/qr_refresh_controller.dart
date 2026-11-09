// The refresh policy for the check-in QR, with no widgets in it so it can be
// tested with a fake clock and fake timers.
//
// Rules (PLANNING.md §5, `mint_qr_token`):
//  * a token's life is measured from LOCAL receipt time, never the server's
//    `expires_at`;
//  * re-mint [refreshMargin] (20 s) before it runs out;
//  * [resume] (app foregrounded / tab shown) re-mints if less than the margin
//    is left, or nothing is on hand;
//  * a transient failure (offline, server hiccup) retries every [retryDelay]
//    (10 s) and the screen says "Reconnecting"; a refusal (the gym says this
//    member can't check in) is NOT retried in a loop -- the person taps retry;
//  * after [dispose] nothing fires and nothing is published.
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:logfitness_membership_flutter/data/qr/qr_token.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';

typedef QrMinter = Future<QrToken> Function();
typedef QrClock = DateTime Function();
typedef QrTimerFactory = Timer Function(Duration delay, void Function() cb);

Timer _realTimer(Duration delay, void Function() cb) => Timer(delay, cb);

/// A token plus the local instant it arrived.
class QrLease {
  const QrLease({required this.token, required this.receivedAt});

  final QrToken token;
  final DateTime receivedAt;

  DateTime get expiresAt => receivedAt.add(token.ttl);

  Duration remaining(DateTime now) {
    final Duration left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}

class QrRefreshController extends ChangeNotifier {
  QrRefreshController({
    required QrMinter mint,
    QrClock? clock,
    QrTimerFactory? timerFactory,
    this.refreshMargin = const Duration(seconds: 20),
    this.retryDelay = const Duration(seconds: 10),
    this.minRefreshWait = const Duration(seconds: 5),
  }) : _mint = mint,
       _clock = clock ?? DateTime.now,
       _timer = timerFactory ?? _realTimer;

  final QrMinter _mint;
  final QrClock _clock;
  final QrTimerFactory _timer;
  final Duration refreshMargin;
  final Duration retryDelay;
  final Duration minRefreshWait;

  QrLease? _lease;
  AppFailure? _failure;
  bool _ineligible = false;
  bool _inFlight = false;
  bool _paused = false;
  bool _disposed = false;
  Timer? _scheduled;

  /// The current token, or null before the first success / after a refusal.
  QrLease? get lease => _lease;

  /// The last mint failure, cleared on the next success.
  AppFailure? get failure => _failure;

  /// True while the gym is refusing this member a code (retry is manual).
  bool get ineligible => _ineligible;

  bool get isMinting => _inFlight;

  /// Nothing has resolved yet.
  bool get isLoading => _lease == null && _failure == null && !_ineligible;

  /// A transient failure is being retried automatically.
  bool get isReconnecting => _failure != null && !_ineligible;

  /// Time left on the token on hand, zero when none / expired.
  Duration remaining() => _lease?.remaining(_clock()) ?? Duration.zero;

  /// A token that is still valid on the local clock.
  bool get hasLiveToken => remaining() > Duration.zero;

  /// Mints now (first load, manual retry). No-op while a mint is running.
  Future<void> mint() => _doMint();

  /// App foregrounded or the tab became visible again.
  Future<void> resume() async {
    if (_disposed) return;
    _paused = false;
    if (_inFlight) return;
    if (_lease == null || remaining() < refreshMargin) {
      await _doMint();
    } else {
      _scheduleRefresh();
    }
  }

  /// App backgrounded or the tab hidden: stop spending RPCs on a screen
  /// nobody can see. [resume] picks up where this left off.
  void pause() {
    _paused = true;
    _cancelTimer();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _scheduled?.cancel();
    _scheduled = null;
  }

  void _scheduleRefresh() {
    _cancelTimer();
    final QrLease? lease = _lease;
    if (_disposed || _paused || lease == null) return;
    final Duration left = lease.remaining(_clock());
    Duration wait = left - refreshMargin;
    if (wait < minRefreshWait) {
      // A short TTL (the server clamps down to 10 s) leaves no room for the
      // margin: refresh at 60 % of what is left instead of hammering the RPC.
      wait = left * 0.6;
    }
    _scheduled = _timer(wait, () => unawaited(_doMint()));
  }

  void _scheduleRetry() {
    _cancelTimer();
    if (_disposed || _paused) return;
    _scheduled = _timer(retryDelay, () => unawaited(_doMint()));
  }

  Future<void> _doMint() async {
    if (_disposed || _inFlight) return;
    _inFlight = true;
    _cancelTimer();
    notifyListeners();
    try {
      final QrToken token = await _mint();
      if (_disposed) return;
      _lease = QrLease(token: token, receivedAt: _clock());
      _failure = null;
      _ineligible = false;
      _inFlight = false;
      _scheduleRefresh();
    } catch (error, stackTrace) {
      if (_disposed) return;
      final AppFailure failure = mapError(error, stackTrace);
      _failure = failure;
      _inFlight = false;
      if (_isTransient(failure)) {
        _ineligible = false;
        // Keep a token that is still valid; the screen hides it the moment
        // it is not.
        _scheduleRetry();
      } else {
        _ineligible = true;
        _lease = null;
        _cancelTimer();
      }
    }
    if (!_disposed) notifyListeners();
  }

  /// Offline, a flaky server, or a session being refreshed: worth retrying
  /// unattended. A refusal / "not found" / validation failure is the gym's
  /// answer and will not fix itself.
  static bool _isTransient(AppFailure failure) => switch (failure.kind) {
    FailureKind.offline ||
    FailureKind.unknown ||
    FailureKind.unauthenticated => true,
    FailureKind.refused ||
    FailureKind.invalid ||
    FailureKind.notFound ||
    FailureKind.duplicate => false,
  };
}
