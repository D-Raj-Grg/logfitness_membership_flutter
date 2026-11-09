import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// A verification-code style PIN entry: six segmented boxes grouped 3 - 3.
///
/// One hidden, transparent [TextField] is the single source of truth (numeric
/// keyboard, digits only, six at most, paste works, backspace walks back). The
/// boxes are only a picture of [controller]. The caller owns [controller] and
/// is responsible for wiping it; this widget never copies the PIN anywhere.
///
/// While [obscure] is true the boxes draw filled dots and the digits never
/// reach a `Text` widget. Screen readers hear "PIN, 3 of 6 digits entered",
/// never the digits.
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

  /// Key of the inner [TextField] (for tests and for the parent).
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
  static const double _dashWidth = 20;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  FocusNode? _ownFocus;
  int _lastLength = 0;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _lastLength = widget.controller.text.length;
    widget.controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(PinBoxes old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
      _lastLength = widget.controller.text.length;
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
    if (widget.shakeTrigger != old.shakeTrigger &&
        !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _ownFocus?.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  void _onTap() {
    if (_focus.hasFocus) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    } else {
      _focus.requestFocus();
    }
  }

  void _onText() {
    final TextEditingController c = widget.controller;
    // The caret is invisible; keep it at the end so a stray tap cannot make
    // the next digit land in the middle of the PIN.
    if (c.selection.baseOffset != c.text.length ||
        c.selection.extentOffset != c.text.length) {
      c.selection = TextSelection.collapsed(offset: c.text.length);
      return; // the selection change notifies again
    }
    final int n = c.text.length;
    final bool completed = n == _length && _lastLength < _length;
    _lastLength = n;
    setState(() {});
    if (completed) {
      widget.onCompleted?.call();
    }
  }

  /// Damped sine: three quick left-right swings.
  double _shakeOffset(double t) => (1 - t) * 10 * math.sin(t * 3 * 2 * math.pi);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String text = widget.controller.text;
    final int count = text.length.clamp(0, _length);
    final bool focused = _focus.hasFocus && widget.enabled;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      textField: true,
      obscured: true,
      enabled: widget.enabled,
      focused: focused,
      label: l10n.authPinSemantics(count),
      onTap: widget.enabled ? _focus.requestFocus : null,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _shake,
          builder: (BuildContext context, Widget? child) => Transform.translate(
            offset: Offset(_shakeOffset(_shake.value), 0),
            child: child,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double groupWidth = (box.maxWidth - _dashWidth) / 2;
              final int active = focused ? text.length.clamp(0, _length - 1) : -1;
              return SizedBox(
                height: _height,
                child: Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _Group(
                          width: groupWidth,
                          start: 0,
                          text: text,
                          active: active,
                          obscure: widget.obscure,
                          hasError: widget.hasError,
                          enabled: widget.enabled,
                        ),
                        SizedBox(
                          width: _dashWidth,
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 2,
                              decoration: BoxDecoration(
                                color: scheme.outline,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        _Group(
                          width: groupWidth,
                          start: 3,
                          text: text,
                          active: active,
                          obscure: widget.obscure,
                          hasError: widget.hasError,
                          enabled: widget.enabled,
                        ),
                      ],
                    ),
                    // Invisible input over the boxes. Its text and caret are
                    // transparent; the digits are drawn by the boxes. (An
                    // obscured field must be single-line, so it cannot stretch
                    // to fill the boxes; the tap catcher below does that.)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: DefaultSelectionStyle(
                        selectionColor: Colors.transparent,
                        cursorColor: Colors.transparent,
                        child: TextField(
                          key: widget.fieldKey,
                          controller: widget.controller,
                          focusNode: _focus,
                          enabled: widget.enabled,
                          maxLength: _length,
                          obscureText: true,
                          showCursor: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const <String>[],
                          enableIMEPersonalizedLearning: false,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSubmitted: (_) => widget.onSubmitted?.call(),
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 40,
                          ),
                          cursorColor: Colors.transparent,
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    // Every tap anywhere on the boxes focuses the input and
                    // (re)opens the keyboard.
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.enabled ? _onTap : null,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Three cells in one rounded container with thin dividers between them.
class _Group extends StatelessWidget {
  const _Group({
    required this.width,
    required this.start,
    required this.text,
    required this.active,
    required this.obscure,
    required this.hasError,
    required this.enabled,
  });

  final double width;
  final int start;
  final String text;
  final int active;
  final bool obscure;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color border = hasError ? scheme.error : scheme.outlineVariant;
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: dark
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          border: Border.all(color: border),
        ),
        // Clip so an active cell's fill follows the group's rounded corners.
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < 3; i++) ...<Widget>[
              if (i > 0) VerticalDivider(width: 1, thickness: 1, color: border),
              Expanded(
                child: _Cell(
                  digit: start + i < text.length ? text[start + i] : null,
                  active: active == start + i,
                  obscure: obscure,
                  hasError: hasError,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.digit,
    required this.active,
    required this.obscure,
    required this.hasError,
  });

  final String? digit;
  final bool active;
  final bool obscure;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool still = MediaQuery.disableAnimationsOf(context);
    final Color accent = hasError ? scheme.error : scheme.primary;
    final TextScaler scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: 1.2);

    Widget? content;
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
    }

    // An empty box shows a faint dot, so six boxes read as a code entry
    // without a "PIN" label.
    content ??= Container(
      key: const ValueKey<String>('pin-empty'),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: active ? 0.0 : 0.22),
        shape: BoxShape.circle,
      ),
    );

    return AnimatedContainer(
      duration: still ? Duration.zero : Brand.motionFast,
      curve: Brand.motionCurve,
      alignment: Alignment.center,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: active ? scheme.primary.withValues(alpha: 0.08) : null,
        border: Border(
          bottom: BorderSide(
            color: active ? accent : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: content,
    );
  }
}
