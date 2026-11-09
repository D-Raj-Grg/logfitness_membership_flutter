import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// A verification-code style PIN entry: six equal boxes in one row.
///
/// The input handling (typing, smooth backspace, paste, haptics, closing the
/// keyboard when the code is complete) is the `pinput` package's; this widget
/// only draws the boxes. The caller owns [controller] and is responsible for
/// wiping it; this widget never copies the PIN anywhere.
///
/// The field is deliberately **not** a secure (`obscureText`) field: on iOS a
/// secure field misbehaves on delete after it regains focus. The dots are drawn
/// here, so the digits never reach a `Text` widget while [obscure] is true.
/// Screen readers hear "PIN, 3 of 6 digits entered", never the digits.
class PinBoxes extends StatefulWidget {
  const PinBoxes({
    required this.controller,
    this.focusNode,
    this.fieldKey,
    this.enabled = true,
    this.obscure = true,
    this.hasError = false,
    this.shakeTrigger = 0,
    this.onCompleted,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;

  /// Optional, so the parent can move focus here ("next" from the card field).
  final FocusNode? focusNode;

  /// Key of the inner pin input (for tests and for the parent).
  final Key? fieldKey;

  final bool enabled;

  /// Dots instead of digits. Default true: the PIN is a secret.
  final bool obscure;

  /// Draws the boxes in the error colour.
  final bool hasError;

  /// Bump this number to play the shake (no-op with reduced motion).
  final int shakeTrigger;

  /// Fires once each time the PIN goes from incomplete to all six digits.
  /// Receives no value on purpose: read [controller] if you need it.
  final VoidCallback? onCompleted;

  /// Keyboard "done" while the PIN is complete or not.
  final VoidCallback? onSubmitted;

  @override
  State<PinBoxes> createState() => _PinBoxesState();
}

class _PinBoxesState extends State<PinBoxes>
    with SingleTickerProviderStateMixin {
  static const int _length = memberPinLength;
  static const double _height = 60;
  static const double _gap = 10;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(PinBoxes old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
    }
    if (widget.shakeTrigger != old.shakeTrigger &&
        !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _shake.dispose();
    super.dispose();
  }

  // Keeps the screen-reader count in step with the field.
  void _onText() => setState(() {});

  /// Damped sine: three quick left-right swings.
  double _shakeOffset(double t) => (1 - t) * 10 * math.sin(t * 3 * 2 * math.pi);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int count = widget.controller.text.length.clamp(0, _length);

    return Semantics(
      container: true,
      textField: true,
      obscured: true,
      enabled: widget.enabled,
      label: l10n.authPinSemantics(count),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _shake,
          builder: (BuildContext context, Widget? child) => Transform.translate(
            offset: Offset(_shakeOffset(_shake.value), 0),
            child: child,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double cell =
                  (box.maxWidth - _gap * (_length - 1)) / _length;
              return Pinput.builder(
                key: widget.fieldKey,
                length: _length,
                controller: widget.controller,
                focusNode: widget.focusNode,
                enabled: widget.enabled,
                autofocus: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                keyboardType: TextInputType.number,
                keyboardAppearance: Theme.of(context).brightness,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                // One light tick per digit; the package closes the keyboard
                // when the sixth digit lands.
                hapticFeedbackType: HapticFeedbackType.selectionClick,
                closeKeyboardWhenCompleted: true,
                mainAxisAlignment: MainAxisAlignment.center,
                separatorBuilder: (int index) => const SizedBox(width: _gap),
                onCompleted: (_) => widget.onCompleted?.call(),
                onSubmitted: (_) => widget.onSubmitted?.call(),
                builder: (BuildContext context, PinItemState state) => SizedBox(
                  width: cell,
                  height: _height,
                  child: _Cell(
                    digit: state.value.isEmpty ? null : state.value,
                    active: state.type == PinItemStateType.focused,
                    obscure: widget.obscure,
                    hasError: widget.hasError,
                    enabled: widget.enabled,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One of the six boxes. Only its border colour animates; its size never
/// changes, so typing and deleting cannot make the row jump.
class _Cell extends StatelessWidget {
  const _Cell({
    required this.digit,
    required this.active,
    required this.obscure,
    required this.hasError,
    required this.enabled,
  });

  final String? digit;
  final bool active;
  final bool obscure;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool still = MediaQuery.disableAnimationsOf(context);
    final bool dark = theme.brightness == Brightness.dark;
    final TextScaler scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: 1.2);

    final Color border = hasError
        ? scheme.error
        : active
        ? scheme.primary
        : scheme.outlineVariant;

    Widget content;
    if (digit != null) {
      content = obscure
          ? Container(
              key: const ValueKey<String>('pin-dot'),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: scheme.onSurface,
                shape: BoxShape.circle,
              ),
            )
          : Text(
              digit!,
              key: const ValueKey<String>('pin-digit'),
              textScaler: scaler,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            );
    } else {
      // An empty box shows a faint dot, so six boxes read as a code entry
      // without a "PIN" label.
      content = Container(
        key: const ValueKey<String>('pin-empty'),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: active ? 0.0 : 0.22),
          shape: BoxShape.circle,
        ),
      );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: AnimatedContainer(
        duration: still ? Duration.zero : Brand.motionFast,
        curve: Brand.motionCurve,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dark
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          border: Border.all(color: border, width: active || hasError ? 2 : 1),
        ),
        child: content,
      ),
    );
  }
}
