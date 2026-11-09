// The check-in tab: scan the QR on the door screen, get attendance marked and
// the door opened. This file is presentation plus the platform glue that needs
// a BuildContext (app lifecycle, "is this the visible tab"); the rules live in
// `CheckInScanController`, the camera behind `DoorScanner`.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/door/door_repository.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/domain/format/money.dart';
import 'package:logfitness_membership_flutter/features/checkin/checkin_result_view.dart';
import 'package:logfitness_membership_flutter/features/checkin/checkin_scan_controller.dart';
import 'package:logfitness_membership_flutter/features/checkin/door_scanner.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Keys the widget tests assert on.
const Key checkinPermissionCardKey = Key('checkin-permission-card');
const Key checkinOpenSettingsKey = Key('checkin-open-settings');
const Key checkinNoCameraKey = Key('checkin-no-camera');
const Key checkinCameraErrorKey = Key('checkin-camera-error');
const Key checkinRetryCameraKey = Key('checkin-retry-camera');
const Key checkinTorchKey = Key('checkin-torch');
const Key checkinForeignHintKey = Key('checkin-foreign-hint');
const Key checkinSubmittingKey = Key('checkin-submitting');
const Key checkinPreviewKey = Key('checkin-preview');

class ScanCheckInScreen extends ConsumerStatefulWidget {
  const ScanCheckInScreen({super.key});

  @override
  ConsumerState<ScanCheckInScreen> createState() => _ScanCheckInScreenState();
}

class _ScanCheckInScreenState extends ConsumerState<ScanCheckInScreen>
    with WidgetsBindingObserver {
  late final DoorScanner _scanner;
  late final CheckInScanController _controller;

  bool _tabVisible = true;
  bool _appResumed = true;
  bool _active = false;
  ScanPhase _lastPhase = ScanPhase.scanning;

  @override
  void initState() {
    super.initState();
    _scanner = ref.read(doorScannerFactoryProvider)();
    _controller = CheckInScanController(
      repository: ref.read(doorRepositoryProvider),
    )..addListener(_onControllerChanged);
    _scanner.codes.listen(_controller.onCodes);
    final AppLifecycleState? lifecycle = WidgetsBinding.instance.lifecycleState;
    _appResumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // StatefulShellRoute.indexedStack keeps every tab alive but wraps the
    // inactive ones in TickerMode(enabled: false): the "am I visible" signal.
    _tabVisible = TickerMode.of(context);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appResumed = state == AppLifecycleState.resumed;
    _sync();
  }

  /// Visible tab + foreground app = camera on. Anything else = camera off.
  /// The permission prompt therefore appears only when the member opens the
  /// tab, never in the background.
  void _sync() {
    final bool shouldBeActive = _tabVisible && _appResumed;
    if (shouldBeActive == _active) return;
    _active = shouldBeActive;
    // Deferred: this can run mid-build (didChangeDependencies).
    Future<void>.microtask(() {
      if (!mounted) return;
      _controller.setActive(shouldBeActive);
      if (shouldBeActive) {
        if (_controller.phase == ScanPhase.scanning) _scanner.start();
      } else {
        _scanner.stop();
      }
    });
  }

  void _onControllerChanged() {
    final ScanPhase phase = _controller.phase;
    if (phase == _lastPhase) return;
    final ScanPhase previous = _lastPhase;
    _lastPhase = phase;
    if (phase == ScanPhase.result) {
      // No camera while a verdict is on screen: saves battery and means the
      // preview cannot re-fire behind the result.
      _scanner.stop();
      if (_controller.result is DoorOk) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    } else if (phase == ScanPhase.scanning &&
        previous != ScanPhase.scanning &&
        _active) {
      _scanner.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _scanner.dispose();
    super.dispose();
  }

  String? _dueText(DoorCheckInResult? r) {
    if (r is! DoorDenied || r.duePaisa == null || r.duePaisa! <= 0) {
      return null;
    }
    final String? currency = ref.read(memberSelfProvider).value?.currency;
    return formatMoney(r.duePaisa!, currency: currency ?? 'NPR');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Brand.tarRoad,
        body: ListenableBuilder(
          listenable: _controller,
          builder: (BuildContext context, _) {
            final bool showResult = _controller.phase == ScanPhase.result;
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _ScannerLayer(scanner: _scanner, controller: _controller),
                if (showResult)
                  CheckinResultView(
                    key: ValueKey<Object?>(
                      _controller.result ?? _controller.failure,
                    ),
                    result: _controller.result,
                    failure: _controller.failure,
                    dueText: _dueText(_controller.result),
                    onClose: _controller.reset,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Camera + overlay, or the state card when the camera cannot run.
class _ScannerLayer extends StatelessWidget {
  const _ScannerLayer({required this.scanner, required this.controller});

  final DoorScanner scanner;
  final CheckInScanController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DoorScannerStatus>(
      valueListenable: scanner.status,
      builder: (BuildContext context, DoorScannerStatus status, _) {
        switch (status) {
          case DoorScannerStatus.permissionDenied:
            return _StateCard(
              key: checkinPermissionCardKey,
              icon: Icons.no_photography_outlined,
              title: AppLocalizations.of(context).checkinPermissionTitle,
              body: AppLocalizations.of(context).checkinPermissionBody,
              actionKey: checkinOpenSettingsKey,
              actionLabel: AppLocalizations.of(context).checkinOpenSettings,
              onAction: scanner.openSettings,
              secondaryKey: checkinRetryCameraKey,
              secondaryLabel: AppLocalizations.of(context).checkinTryAgain,
              onSecondary: scanner.start,
            );
          case DoorScannerStatus.noCamera:
            return _StateCard(
              key: checkinNoCameraKey,
              icon: Icons.videocam_off_outlined,
              title: AppLocalizations.of(context).checkinNoCameraTitle,
              body: AppLocalizations.of(context).checkinNoCameraBody,
            );
          case DoorScannerStatus.error:
            return _StateCard(
              key: checkinCameraErrorKey,
              icon: Icons.videocam_off_outlined,
              title: AppLocalizations.of(context).checkinCameraErrorTitle,
              body: AppLocalizations.of(context).checkinCameraErrorBody,
              actionKey: checkinRetryCameraKey,
              actionLabel: AppLocalizations.of(context).checkinTryAgain,
              onAction: scanner.start,
            );
          case DoorScannerStatus.starting:
          case DoorScannerStatus.running:
          case DoorScannerStatus.stopped:
            return _Viewfinder(scanner: scanner, controller: controller);
        }
      },
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.scanner, required this.controller});

  final DoorScanner scanner;
  final CheckInScanController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Semantics(
      label: l10n.checkinCameraSemantics,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          KeyedSubtree(
            key: checkinPreviewKey,
            child: scanner.buildPreview(context),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double side = (c.biggest.shortestSide * 0.7).clamp(
                200.0,
                340.0,
              );
              final Rect window = Rect.fromCenter(
                center: Offset(c.maxWidth / 2, c.maxHeight * 0.45),
                width: side,
                height: side,
              );
              return IgnorePointer(
                child: CustomPaint(painter: _FramePainter(window)),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Brand.gutter,
                Brand.spaceLg,
                Brand.gutter,
                Brand.spaceMd,
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    l10n.checkinInstruction,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Brand.paper,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  ListenableBuilder(
                    listenable: controller,
                    builder: (BuildContext context, _) {
                      if (controller.phase == ScanPhase.submitting) {
                        return _Pill(
                          key: checkinSubmittingKey,
                          leading: const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Brand.paper,
                            ),
                          ),
                          text: l10n.checkinCheckingIn,
                        );
                      }
                      if (controller.foreignHint) {
                        return _Pill(
                          key: checkinForeignHintKey,
                          text: l10n.checkinForeignHint,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: Brand.spaceMd),
                  _TorchButton(scanner: scanner),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.leading, super.key});

  final String text;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceMd,
          vertical: Brand.spaceSm,
        ),
        decoration: BoxDecoration(
          color: Brand.tarRoadElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(Brand.radiusLarge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: Brand.spaceSm),
            ],
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Brand.paper),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.scanner});

  final DoorScanner scanner;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<DoorTorch>(
      valueListenable: scanner.torch,
      builder: (BuildContext context, DoorTorch torch, _) {
        if (torch == DoorTorch.unavailable) return const SizedBox.shrink();
        final bool on = torch == DoorTorch.on;
        return Semantics(
          button: true,
          toggled: on,
          label: on ? l10n.checkinTorchOff : l10n.checkinTorchOn,
          child: IconButton.filled(
            key: checkinTorchKey,
            onPressed: scanner.toggleTorch,
            iconSize: 28,
            style: IconButton.styleFrom(
              minimumSize: const Size(56, 56),
              backgroundColor: on ? Brand.paper : Brand.tarRoadElevated,
              foregroundColor: on ? Brand.tarRoad : Brand.paper,
            ),
            icon: Icon(
              on ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
            ),
          ),
        );
      },
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionKey,
    this.actionLabel,
    this.onAction,
    this.secondaryKey,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? secondaryKey;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Brand.gutter),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding: const EdgeInsets.all(Brand.spaceLg),
              decoration: BoxDecoration(
                color: Brand.tarRoadElevated,
                borderRadius: BorderRadius.circular(Brand.radiusCard),
                border: Border.all(color: Brand.elegantGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 44, color: Brand.elegantGrey),
                  const SizedBox(height: Brand.spaceMd),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Brand.paper,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Brand.spaceSm),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Brand.elegantGrey,
                    ),
                  ),
                  if (actionLabel != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceLg),
                    FilledButton(
                      key: actionKey,
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: Brand.paper,
                        foregroundColor: Brand.tarRoad,
                        minimumSize: const Size.fromHeight(Brand.buttonHeight),
                      ),
                      child: Text(actionLabel!),
                    ),
                  ],
                  if (secondaryLabel != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceSm),
                    TextButton(
                      key: secondaryKey,
                      onPressed: onSecondary,
                      style: TextButton.styleFrom(
                        foregroundColor: Brand.paper,
                        minimumSize: const Size.fromHeight(Brand.buttonHeight),
                      ),
                      child: Text(secondaryLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dimmed surround with a rounded clear window and four corner brackets.
class _FramePainter extends CustomPainter {
  const _FramePainter(this.window);

  final Rect window;

  static const double _radius = 28;
  static const double _arm = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect hole = RRect.fromRectAndRadius(
      window,
      const Radius.circular(_radius),
    );
    final Path dim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(hole),
    );
    canvas.drawPath(dim, Paint()..color = const Color(0x99000000));

    final Paint bracket = Paint()
      ..color = Brand.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    // Each corner: an arc plus two straight arms, drawn as one path.
    final Rect w = window;
    final Path p = Path()
      // top-left
      ..moveTo(w.left, w.top + _radius + _arm)
      ..lineTo(w.left, w.top + _radius)
      ..arcToPoint(
        Offset(w.left + _radius, w.top),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(w.left + _radius + _arm, w.top)
      // top-right
      ..moveTo(w.right - _radius - _arm, w.top)
      ..lineTo(w.right - _radius, w.top)
      ..arcToPoint(
        Offset(w.right, w.top + _radius),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(w.right, w.top + _radius + _arm)
      // bottom-right
      ..moveTo(w.right, w.bottom - _radius - _arm)
      ..lineTo(w.right, w.bottom - _radius)
      ..arcToPoint(
        Offset(w.right - _radius, w.bottom),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(w.right - _radius - _arm, w.bottom)
      // bottom-left
      ..moveTo(w.left + _radius + _arm, w.bottom)
      ..lineTo(w.left + _radius, w.bottom)
      ..arcToPoint(
        Offset(w.left, w.bottom - _radius),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(w.left, w.bottom - _radius - _arm);
    canvas.drawPath(p, bracket);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.window != window;
}
