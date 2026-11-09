// The check-in tab: a white "ticket" with the member's QR on a brand-tone
// ground. The refresh policy lives in `QrRefreshController`; this file is
// presentation plus the two pieces of platform glue that need a BuildContext:
// app lifecycle and "is this tab the visible one".
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/qr/qr_token_repository.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/features/qr/qr_brightness.dart';
import 'package:logfitness_membership_flutter/features/qr/qr_refresh_controller.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Keys the widget tests assert on.
const Key qrTicketKey = Key('qr-ticket');
const Key qrReconnectingKey = Key('qr-reconnecting');
const Key qrNotEligibleKey = Key('qr-not-eligible');
const Key qrCheckAgainKey = Key('qr-check-again');

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen>
    with WidgetsBindingObserver {
  late final QrRefreshController _controller;
  late final QrBrightness _brightness;

  bool _tabVisible = true;
  bool _appResumed = true;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _controller = QrRefreshController(
      mint: () => ref.read(qrTokenRepositoryProvider).mint(),
    );
    _brightness = ref.read(qrBrightnessProvider);
    final AppLifecycleState? lifecycle =
        WidgetsBinding.instance.lifecycleState;
    _appResumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    // The first mint happens in the first didChangeDependencies -> _sync.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StatefulShellRoute.indexedStack keeps every tab alive but wraps the
    // inactive ones in TickerMode(enabled: false), so this is the tab's
    // "am I the visible one" signal, and it flips with no router plumbing.
    _tabVisible = TickerMode.of(context);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _sync();
  }

  /// Visible tab + foreground app = active: boost brightness and keep the
  /// code fresh. Anything else: give the brightness back and stop minting.
  void _sync() {
    final bool shouldBeActive = _tabVisible && _appResumed;
    if (shouldBeActive == _active) return;
    _active = shouldBeActive;
    // Deferred: this runs from didChangeDependencies, i.e. mid-build, and the
    // controller notifies its listeners synchronously.
    if (shouldBeActive) {
      _brightness.boost();
      Future<void>.microtask(_controller.resume);
    } else {
      _brightness.restore();
      Future<void>.microtask(_controller.pause);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_active) {
      _brightness.restore();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AsyncValue<CurrentMember> me = ref.watch(memberSelfProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Brand.tarRoad,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Brand.gutter,
                vertical: Brand.spaceLg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (BuildContext context, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        l10n.qrHeadline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Brand.paper,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Brand.spaceLg),
                      if (_controller.ineligible)
                        _NotEligibleCard(
                          message: _controller.failure?.message ?? '',
                          onRetry: _controller.mint,
                        )
                      else ...<Widget>[
                        _Ticket(
                          controller: _controller,
                          name: me.value?.fullName,
                          code: me.value?.memberCode,
                          loadingName: me.isLoading,
                        ),
                        const SizedBox(height: Brand.spaceLg),
                        _StatusLine(controller: _controller),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The white ticket. Always white with a black code, whatever the app theme:
/// scanners need dark-on-light contrast and a clear quiet zone.
class _Ticket extends StatelessWidget {
  const _Ticket({
    required this.controller,
    required this.name,
    required this.code,
    required this.loadingName,
  });

  final QrRefreshController controller;
  final String? name;
  final String? code;
  final bool loadingName;

  static const double _notch = 14;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final QrLease? lease = controller.lease;
    final bool live = lease != null && controller.hasLiveToken;
    final bool expired = lease != null && !live;

    return Semantics(
      container: true,
      label: name == null
          ? l10n.qrSemanticsLabelNoName
          : l10n.qrSemanticsLabel(name!),
      image: true,
      child: Container(
        key: qrTicketKey,
        decoration: BoxDecoration(
          color: Brand.white,
          borderRadius: BorderRadius.circular(Brand.radiusCard),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              // Generous padding doubles as the QR's quiet zone.
              padding: const EdgeInsets.fromLTRB(
                Brand.spaceLg,
                Brand.spaceLg,
                Brand.spaceLg,
                Brand.spaceMd,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: live
                    ? QrImageView(
                        key: ValueKey<String>('qr-image:${lease.token.token}'),
                        data: lease.token.token,
                        padding: const EdgeInsets.all(Brand.spaceSm),
                        backgroundColor: Brand.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      )
                    : _QrPlaceholder(
                        label: expired ? l10n.qrExpired : l10n.qrLoading,
                        busy: !expired,
                      ),
              ),
            ),
            // Perforation with side notches, the "ticket" cue.
            SizedBox(
              height: _notch * 2,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    left: -_notch,
                    child: _notchCircle(),
                  ),
                  Positioned(
                    right: -_notch,
                    child: _notchCircle(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Brand.spaceLg),
                    child: _DashedLine(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Brand.spaceLg,
                Brand.spaceSm,
                Brand.spaceLg,
                Brand.spaceMd,
              ),
              child: Column(
                children: <Widget>[
                  if (name != null)
                    Text(
                      name!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Brand.tarRoad,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (loadingName)
                    const SkeletonBox(width: 160, height: 22),
                  if (code != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      l10n.qrMemberCode(code!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Brand.greyInk,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Brand.spaceMd),
                  _Countdown(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notchCircle() => Container(
    width: _notch * 2,
    height: _notch * 2,
    decoration: const BoxDecoration(
      color: Brand.tarRoad,
      shape: BoxShape.circle,
    ),
  );
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder({required this.label, required this.busy});

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (busy)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Brand.tarRoad,
                ),
              )
            else
              const Icon(
                Icons.qr_code_2_rounded,
                size: 48,
                color: Brand.elegantGrey,
              ),
            const SizedBox(height: Brand.spaceSm),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Brand.greyInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        const double dash = 6;
        const double gap = 5;
        final int count = (c.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (_) => Container(
              width: dash,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFD5D8DD),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Thin bar + "Refreshes in Ns". Owns a Ticker so only this small subtree
/// repaints each frame (the QR itself is not rebuilt), and the ticker stops by
/// itself when the tab is hidden.
class _Countdown extends StatefulWidget {
  const _Countdown({required this.controller});

  final QrRefreshController controller;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => setState(() {}))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QrLease? lease = widget.controller.lease;
    final Duration left = widget.controller.remaining();
    final double fraction = lease == null || lease.token.ttl == Duration.zero
        ? 0
        : (left.inMilliseconds / lease.token.ttl.inMilliseconds).clamp(
            0.0,
            1.0,
          );
    final int seconds = (left.inMilliseconds / 1000).ceil();

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(Brand.radiusPill),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: <Widget>[
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFFE4E6EA)),
                ),
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: const ColoredBox(color: Brand.tarRoad),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Brand.spaceSm),
        Text(
          lease == null || left == Duration.zero
              ? ' '
              : l10n.qrSecondsLeft(seconds),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Brand.greyInk,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Calm line under the ticket: the reassuring subtitle, or the
/// "Reconnecting…" pill while retries run.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.controller});

  final QrRefreshController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    if (controller.isReconnecting) {
      return Column(
        key: qrReconnectingKey,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Brand.spaceMd,
              vertical: Brand.spaceSm,
            ),
            decoration: BoxDecoration(
              color: Brand.tarRoadElevated,
              borderRadius: BorderRadius.circular(Brand.radiusPill),
              border: Border.all(color: Brand.elegantGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Brand.paper,
                  ),
                ),
                const SizedBox(width: Brand.spaceSm),
                Text(
                  l10n.qrReconnecting,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Brand.paper,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Brand.spaceSm),
          Text(
            l10n.qrReconnectingHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Brand.elegantGrey,
            ),
          ),
        ],
      );
    }
    return Text(
      l10n.qrSubtitle,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(color: Brand.elegantGrey),
    );
  }
}

/// Shown instead of a QR when the gym refuses the member a code. Renders the
/// gym's own sentence verbatim, then says what it means for the door.
class _NotEligibleCard extends StatelessWidget {
  const _NotEligibleCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Container(
      key: qrNotEligibleKey,
      padding: const EdgeInsets.all(Brand.spaceLg),
      decoration: BoxDecoration(
        color: Brand.tarRoadElevated,
        borderRadius: BorderRadius.circular(Brand.radiusCard),
        border: Border.all(color: Brand.elegantGrey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.qr_code_2_rounded,
            size: 40,
            color: Brand.elegantGrey,
          ),
          const SizedBox(height: Brand.spaceMd),
          Text(
            l10n.qrNotEligibleTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Brand.paper,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Brand.spaceSm),
          if (message.isNotEmpty)
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Brand.paper),
            ),
          const SizedBox(height: Brand.spaceSm),
          Text(
            l10n.qrNotEligibleBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Brand.elegantGrey,
            ),
          ),
          const SizedBox(height: Brand.spaceLg),
          OutlinedButton(
            key: qrCheckAgainKey,
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Brand.paper,
              side: const BorderSide(color: Brand.elegantGrey),
              minimumSize: const Size.fromHeight(Brand.buttonHeight),
            ),
            child: Text(l10n.qrCheckAgain),
          ),
        ],
      ),
    );
  }
}
