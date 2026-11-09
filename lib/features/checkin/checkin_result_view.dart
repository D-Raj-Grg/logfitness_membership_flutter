// Full-screen verdict after a scan. Status is never colour alone: each outcome
// has its own icon and its own words.
import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/door/door_check_in_result.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Keys the widget tests assert on.
const Key checkinOkKey = Key('checkin-ok');
const Key checkinDeniedKey = Key('checkin-denied');
const Key checkinInvalidKey = Key('checkin-invalid');
const Key checkinClosedKey = Key('checkin-closed');
const Key checkinRateLimitedKey = Key('checkin-rate-limited');
const Key checkinOfflineKey = Key('checkin-offline');
const Key checkinUnknownKey = Key('checkin-unknown');
const Key checkinScanAgainKey = Key('checkin-scan-again');

class CheckinResultView extends StatelessWidget {
  const CheckinResultView({
    required this.onClose,
    this.result,
    this.failure,
    this.dueText,
    super.key,
  }) : assert(
         result != null || failure != null,
         'Show either a server answer or a failure.',
       );

  /// The server's answer. Null when the call itself failed ([failure]).
  final DoorCheckInResult? result;
  final AppFailure? failure;

  /// Dues already formatted with the org's currency, if known.
  final String? dueText;

  /// Back to the scanner.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DoorCheckInResult? r = result;

    if (r is DoorOk) {
      return _OkView(result: r, onClose: onClose);
    }

    final _Spec spec = switch (r) {
      DoorDenied() => _Spec(
        key: checkinDeniedKey,
        icon: Icons.block_rounded,
        title: l10n.checkinDeniedTitle,
        body: switch (r.reason) {
          DoorDeniedReason.expired => l10n.checkinDeniedExpired,
          DoorDeniedReason.dues =>
            dueText != null
                ? l10n.checkinDeniedDuesAmount(dueText!)
                : l10n.checkinDeniedDues,
          DoorDeniedReason.frozen => l10n.checkinDeniedFrozen,
          DoorDeniedReason.other => l10n.checkinDeniedOther,
        },
        footnote: l10n.checkinDeniedHint,
        action: l10n.checkinTryAgain,
        alert: true,
      ),
      DoorInvalidCode() => _Spec(
        key: checkinInvalidKey,
        icon: Icons.timer_off_outlined,
        title: l10n.checkinInvalidTitle,
        body: l10n.checkinInvalidBody,
        action: l10n.checkinScanAgain,
      ),
      DoorClosed() => _Spec(
        key: checkinClosedKey,
        icon: Icons.lock_clock_outlined,
        title: l10n.checkinClosedTitle,
        body: l10n.checkinClosedBody,
        action: l10n.checkinScanAgain,
      ),
      DoorRateLimited() => _Spec(
        key: checkinRateLimitedKey,
        icon: Icons.hourglass_top_rounded,
        title: l10n.checkinRateTitle,
        body: l10n.checkinRateBody,
        action: l10n.checkinScanAgain,
      ),
      _ when failure?.kind == FailureKind.offline => _Spec(
        key: checkinOfflineKey,
        icon: Icons.wifi_off_rounded,
        title: l10n.checkinOfflineTitle,
        body: l10n.checkinOfflineBody,
        action: l10n.checkinTryAgain,
      ),
      _ => _Spec(
        key: checkinUnknownKey,
        icon: Icons.error_outline_rounded,
        title: l10n.checkinUnknownTitle,
        body: l10n.checkinUnknownBody,
        action: l10n.checkinTryAgain,
      ),
    };

    return _Panel(
      key: spec.key,
      onClose: null,
      child: _MessageBody(spec: spec, onAction: onClose),
    );
  }
}

class _Spec {
  const _Spec({
    required this.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    this.footnote,
    this.alert = false,
  });

  final Key key;
  final IconData icon;
  final String title;
  final String body;
  final String? footnote;
  final String action;
  final bool alert;
}

/// Opaque dark ground over the camera; optionally tap-anywhere-to-close.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, required this.onClose, super.key});

  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Brand.tarRoad,
      child: InkWell(
        onTap: onClose,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Brand.gutter,
                vertical: Brand.spaceLg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.spec, required this.onAction});

  final _Spec spec;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = spec.alert
        ? theme.colorScheme.error
        : Brand.elegantGrey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          liveRegion: true,
          child: Icon(spec.icon, size: 64, color: iconColor),
        ),
        const SizedBox(height: Brand.spaceMd),
        Text(
          spec.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Brand.paper,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Brand.spaceSm),
        Text(
          spec.body,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: Brand.paper),
        ),
        if (spec.footnote != null) ...<Widget>[
          const SizedBox(height: Brand.spaceSm),
          Text(
            spec.footnote!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Brand.elegantGrey,
            ),
          ),
        ],
        const SizedBox(height: Brand.spaceLg),
        FilledButton(
          key: checkinScanAgainKey,
          onPressed: onAction,
          style: FilledButton.styleFrom(
            backgroundColor: Brand.paper,
            foregroundColor: Brand.tarRoad,
            minimumSize: const Size.fromHeight(Brand.buttonHeight),
          ),
          child: Text(spec.action),
        ),
      ],
    );
  }
}

class _OkView extends StatelessWidget {
  const _OkView({required this.result, required this.onClose});

  final DoorOk result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final String title = result.alreadyCheckedInToday
        ? l10n.checkinOkWelcomeBack
        : l10n.checkinOkTitle;
    final String? first = result.firstName;
    final int? days = result.daysToExpiry;

    return _Panel(
      key: checkinOkKey,
      onClose: onClose,
      child: Semantics(
        liveRegion: true,
        label: title,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: reduceMotion ? 1 : 0, end: 1),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (BuildContext context, double t, Widget? child) =>
                  Transform.scale(scale: t.clamp(0.0, 1.4), child: child),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Brand.paper,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 80,
                  color: Brand.tarRoad,
                ),
              ),
            ),
            const SizedBox(height: Brand.spaceLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Brand.paper,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (first != null) ...<Widget>[
              const SizedBox(height: Brand.spaceSm),
              Text(
                l10n.checkinOkGreeting(first),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(color: Brand.paper),
              ),
            ],
            if (days != null && days >= 0) ...<Widget>[
              const SizedBox(height: Brand.spaceXs),
              Text(
                l10n.checkinDaysLeft(days),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Brand.elegantGrey,
                ),
              ),
            ],
            const SizedBox(height: Brand.spaceXl),
            Text(
              l10n.checkinTapToClose,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Brand.elegantGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
