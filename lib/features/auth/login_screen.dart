import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/common/log_mark.dart';
import 'package:logfitness_membership_flutter/features/auth/pin_boxes.dart';
import 'package:logfitness_membership_flutter/features/auth/screen_security.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key loginIdentifierFieldKey = Key('login-identifier');
const Key loginPinFieldKey = Key('login-pin');
const Key loginSubmitKey = Key('login-submit');
const Key loginErrorKey = Key('login-error');
const Key loginKeyboardDoneKey = Key('login-keyboard-done');

/// Which message the form shows. Deliberately coarse: wrong card, wrong PIN,
/// unknown member and unassigned card are all [invalid] (CLAUDE.md: one
/// generic failure).
sealed class LoginError {
  const LoginError();
}

final class LoginErrorInvalid extends LoginError {
  const LoginErrorInvalid();
}

final class LoginErrorLocked extends LoginError {
  const LoginErrorLocked(this.minutes);

  final int minutes;
}

final class LoginErrorRateLimited extends LoginError {
  const LoginErrorRateLimited();
}

final class LoginErrorOffline extends LoginError {
  const LoginErrorOffline();
}

final class LoginErrorUnknown extends LoginError {
  const LoginErrorUnknown();
}

/// Maps a repository result to the error to show, or null on success.
/// Pure so it is unit-tested without a widget.
LoginError? loginErrorFor(LoginResult result) => switch (result) {
  LoginOk() => null,
  LoginInvalid() => const LoginErrorInvalid(),
  LoginLocked(:final int retryAfterSeconds) => LoginErrorLocked(
    // Round up so "0 minutes" is never shown; at least one.
    (retryAfterSeconds / 60).ceil().clamp(1, 24 * 60),
  ),
  LoginRateLimited() => const LoginErrorRateLimited(),
  LoginFailed(:final AppFailure failure) =>
    failure.kind == FailureKind.offline
        ? const LoginErrorOffline()
        : const LoginErrorUnknown(),
};

/// Longest printed card number (0001-9999).
const int kCardNumberMaxDigits = 4;

/// A phone number is exactly ten digits (every LOG member's is).
const int kPhoneDigits = 10;

/// 1-4 digits = printed card number, exactly 10 = phone (PLANNING 4.1).
/// Anything else can never match, so it is never sent.
bool isPlausibleIdentifier(String digits) {
  final int n = digits.length;
  return (n >= 1 && n <= kCardNumberMaxDigits) || n == kPhoneDigits;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Lets the sixth dot show for a beat before the sign-in starts.
  static const Duration _autoSubmitDelay = Duration(milliseconds: 160);

  // Local controllers only: the PIN never enters provider state.
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  final FocusNode _identifierFocus = FocusNode();

  Timer? _autoSubmit;
  bool _busy = false;
  int _shake = 0;
  LoginError? _error;

  @override
  void initState() {
    super.initState();
    ScreenSecurity.setSecure(true);
    _identifier.addListener(_onIdentifierChanged);
    _pin.addListener(_onChanged);
    _identifierFocus.addListener(_onChanged);
    _pinFocus.addListener(_onChanged);
  }

  @override
  void dispose() {
    ScreenSecurity.setSecure(false);
    _autoSubmit?.cancel();
    _identifier.removeListener(_onIdentifierChanged);
    _pin.removeListener(_onChanged);
    _identifierFocus.removeListener(_onChanged);
    _pinFocus.removeListener(_onChanged);
    _pin.clear();
    _pin.dispose();
    _identifier.dispose();
    _pinFocus.dispose();
    _identifierFocus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  /// The tenth digit completes a phone number: carry on into the PIN boxes.
  /// (A card number is 1-4 digits, so it cannot be told apart from a half
  /// typed phone; those members tap the boxes.)
  void _onIdentifierChanged() {
    setState(() {});
    if (_identifier.text.length == kPhoneDigits && _identifierFocus.hasFocus) {
      _pinFocus.requestFocus();
    }
  }

  bool get _keyboardOpen => _identifierFocus.hasFocus || _pinFocus.hasFocus;

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  bool get _identifierValid => isPlausibleIdentifier(_identifier.text.trim());

  bool get _pinComplete => isValidMemberPin(_pin.text);

  /// The button and the auto-submit share this one gate, so they can never
  /// both fire: [_submit] sets [_busy] before its first await.
  bool get _canSubmit => !_busy && _identifierValid && _pinComplete;

  /// Fires when the 6th digit is typed or pasted. Only submits if the card or
  /// phone is already valid; otherwise the button does it later.
  void _onPinCompleted() {
    // Six digits in: the keyboard has nothing more to do.
    _pinFocus.unfocus();
    if (!_identifierValid || _busy) {
      return;
    }
    _autoSubmit?.cancel();
    _autoSubmit = Timer(_autoSubmitDelay, () {
      if (mounted && _canSubmit) {
        _submit();
      }
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }
    _autoSubmit?.cancel();
    final String identifier = _identifier.text.trim();
    final String pin = _pin.text;
    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });
    // The PIN is wiped from the field right away; the local `pin` lives only
    // until the call below returns.
    _pin.clear();

    final LoginResult result = await ref
        .read(memberAuthRepositoryProvider)
        .login(identifier: identifier, pin: pin);

    if (!mounted) {
      return;
    }
    // On success the session change makes the router leave this screen.
    final LoginError? error = loginErrorFor(result);
    setState(() {
      _busy = false;
      _error = error;
      if (error != null) {
        _shake++;
      }
    });
    if (error != null) {
      unawaited(HapticFeedback.mediumImpact());
      _pin.clear();
      // The boxes are disabled until this frame is built; focus after it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pinFocus.requestFocus();
        }
      });
    }
  }

  String _message(AppLocalizations l10n, LoginError e) => switch (e) {
    LoginErrorInvalid() => l10n.authErrorInvalid,
    LoginErrorLocked(:final int minutes) => l10n.authErrorLocked(minutes),
    LoginErrorRateLimited() => l10n.authErrorRateLimited,
    LoginErrorOffline() => l10n.authErrorOffline,
    LoginErrorUnknown() => l10n.authErrorUnknown,
  };

  /// The login is always the brand's dark ground (#17181D), in light and dark
  /// mode: it matches the native launch screen, so opening the app has no
  /// colour change, and the white LOG mark is the one thing on the screen.
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appDarkTheme,
      child: Builder(
        builder: (BuildContext context) =>
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: _buildBody(context),
            ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool still = MediaQuery.disableAnimationsOf(context);
    // Only nag about the card/phone once the PIN is in and the button would
    // otherwise stay silently disabled.
    final bool identifierProblem =
        _pinComplete && _identifier.text.isNotEmpty && !_identifierValid;

    final bool kb = _keyboardOpen;
    return Scaffold(
      body: GestureDetector(
        // A tap on empty space puts the keyboard away. (Taps on the fields are
        // handled by the fields first.)
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SafeArea(
                bottom: !kb,
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Brand.gutter,
                      vertical: Brand.spaceLg,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: still
                            ? Duration.zero
                            : const Duration(milliseconds: 600),
                        curve: Brand.motionCurve,
                        builder:
                            (BuildContext context, double t, Widget? child) =>
                                Opacity(
                                  opacity: t,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - t) * 24),
                                    child: child,
                                  ),
                                ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // The mark shrinks while the keyboard is up, so the field,
                            // the boxes and the button all stay on screen.
                            Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(end: kb ? 88 : 168),
                                duration: still
                                    ? Duration.zero
                                    : Brand.motionBase,
                                curve: Brand.motionCurve,
                                builder:
                                    (
                                      BuildContext context,
                                      double size,
                                      Widget? _,
                                    ) => LogMark(size: size),
                              ),
                            ),
                            AnimatedContainer(
                              duration: still
                                  ? Duration.zero
                                  : Brand.motionBase,
                              curve: Brand.motionCurve,
                              height: kb ? 28 : 64,
                            ),
                            TextField(
                              key: loginIdentifierFieldKey,
                              controller: _identifier,
                              focusNode: _identifierFocus,
                              enabled: !_busy,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: const <String>[],
                              enableIMEPersonalizedLearning: false,
                              maxLength: kPhoneDigits,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSubmitted: (_) => _pinFocus.requestFocus(),
                              decoration: InputDecoration(
                                hintText: l10n.authIdentifierLabel,
                                errorText: identifierProblem
                                    ? l10n.authIdentifierInvalid
                                    : null,
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: Brand.spaceMd),
                            PinBoxes(
                              fieldKey: loginPinFieldKey,
                              controller: _pin,
                              focusNode: _pinFocus,
                              enabled: !_busy,
                              obscure: true,
                              hasError: _error != null && _pin.text.isEmpty,
                              shakeTrigger: _shake,
                              onCompleted: _onPinCompleted,
                              onSubmitted: _submit,
                            ),
                            AnimatedSize(
                              duration: still
                                  ? Duration.zero
                                  : Brand.motionBase,
                              curve: Brand.motionCurve,
                              alignment: Alignment.topCenter,
                              child: _error == null
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                        top: Brand.spaceMd,
                                      ),
                                      child: _ErrorBanner(
                                        message: _message(l10n, _error!),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: Brand.spaceLg),
                            SizedBox(
                              height: Brand.buttonHeight,
                              child: FilledButton(
                                key: loginSubmitKey,
                                onPressed: _canSubmit ? _submit : null,
                                child: _busy
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: scheme.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: Brand.spaceSm + 4,
                                          ),
                                          Text(l10n.authSigningIn),
                                        ],
                                      )
                                    : Text(l10n.authSignIn),
                              ),
                            ),
                            const SizedBox(height: Brand.spaceLg),
                            Text(
                              l10n.authForgotPin,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (kb)
              _KeyboardDoneBar(
                key: loginKeyboardDoneKey,
                label: l10n.authKeyboardDone,
                onPressed: _dismissKeyboard,
              ),
          ],
        ),
      ),
    );
  }
}

/// A slim bar docked above the keyboard. The iPhone number pad has no Return
/// key, so without this there is no way to put the keyboard away.
class _KeyboardDoneBar extends StatelessWidget {
  const _KeyboardDoneBar({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SizedBox(
        height: 44,
        width: double.infinity,
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              minimumSize: const Size(72, 44),
              padding: const EdgeInsets.symmetric(horizontal: Brand.gutter),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        key: loginErrorKey,
        padding: const EdgeInsets.all(Brand.spaceMd - 2),
        decoration: BoxDecoration(
          color: s.errorContainer,
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          border: Border.all(color: s.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: s.onErrorContainer, size: 20),
            const SizedBox(width: Brand.spaceSm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: s.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
