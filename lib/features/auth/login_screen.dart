import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
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

/// 1-4 digits = printed card number, 7-15 = phone (PLANNING 4.1). Anything
/// else can never match, so it is never sent.
bool isPlausibleIdentifier(String digits) {
  final int n = digits.length;
  return (n >= 1 && n <= 4) || (n >= 7 && n <= 15);
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

  Timer? _autoSubmit;
  bool _busy = false;
  bool _showPin = false;
  int _shake = 0;
  LoginError? _error;

  @override
  void initState() {
    super.initState();
    ScreenSecurity.setSecure(true);
    _identifier.addListener(_onChanged);
    _pin.addListener(_onChanged);
  }

  @override
  void dispose() {
    ScreenSecurity.setSecure(false);
    _autoSubmit?.cancel();
    _identifier.removeListener(_onChanged);
    _pin.removeListener(_onChanged);
    _pin.clear();
    _pin.dispose();
    _identifier.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _identifierValid => isPlausibleIdentifier(_identifier.text.trim());

  bool get _pinComplete => isValidMemberPin(_pin.text);

  /// The button and the auto-submit share this one gate, so they can never
  /// both fire: [_submit] sets [_busy] before its first await.
  bool get _canSubmit => !_busy && _identifierValid && _pinComplete;

  /// Fires when the 6th digit is typed or pasted. Only submits if the card or
  /// phone is already valid; otherwise the button does it later.
  void _onPinCompleted() {
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool still = MediaQuery.disableAnimationsOf(context);
    // Only nag about the card/phone once the PIN is in and the button would
    // otherwise stay silently disabled.
    final bool identifierProblem =
        _pinComplete && _identifier.text.isNotEmpty && !_identifierValid;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: Brand.gutter,
              vertical: Brand.spaceLg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: still ? Duration.zero : const Duration(milliseconds: 600),
                curve: Brand.motionCurve,
                builder: (BuildContext context, double t, Widget? child) =>
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
                    const Center(child: _LoginLogo()),
                    const SizedBox(height: Brand.spaceMd),
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      l10n.authTagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceXl),
                    Text(
                      l10n.authSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceMd),
                    TextField(
                      key: loginIdentifierFieldKey,
                      controller: _identifier,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const <String>[],
                      enableIMEPersonalizedLearning: false,
                      maxLength: 15,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSubmitted: (_) => _pinFocus.requestFocus(),
                      decoration: InputDecoration(
                        labelText: l10n.authIdentifierLabel,
                        hintText: l10n.authIdentifierHint,
                        errorText: identifierProblem
                            ? l10n.authIdentifierInvalid
                            : null,
                        counterText: '',
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: Brand.spaceLg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            l10n.authPinLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _showPin ? l10n.authHidePin : l10n.authShowPin,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          icon: Icon(
                            _showPin
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _showPin = !_showPin),
                        ),
                      ],
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    PinBoxes(
                      fieldKey: loginPinFieldKey,
                      controller: _pin,
                      focusNode: _pinFocus,
                      enabled: !_busy,
                      obscure: !_showPin,
                      hasError: _error != null && _pin.text.isEmpty,
                      shakeTrigger: _shake,
                      onCompleted: _onPinCompleted,
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: Brand.spaceSm),
                    Text(
                      l10n.authPinHelper,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    AnimatedSize(
                      duration: still ? Duration.zero : Brand.motionBase,
                      curve: Brand.motionCurve,
                      alignment: Alignment.topCenter,
                      child: _error == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: Brand.spaceMd),
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
                                  const SizedBox(width: Brand.spaceSm + 4),
                                  Text(l10n.authSigningIn),
                                ],
                              )
                            : Text(l10n.authSignIn),
                      ),
                    ),
                    const SizedBox(height: Brand.spaceLg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.support_agent_outlined,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Brand.spaceSm),
                        Expanded(
                          child: Text(
                            l10n.authForgotPin,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

/// The real LOG mark on its dark tile, with a hairline ring so the tile stays
/// visible on the dark theme too.
class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    const double size = 88;
    return Semantics(
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 96 / 512),
          border: Border.all(color: Brand.elegantGrey, width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Brand.tarRoad.withValues(alpha: 0.28),
              blurRadius: 26,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const LogMark(size: size, withTile: true),
      ),
    );
  }
}
