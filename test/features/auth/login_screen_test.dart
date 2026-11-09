import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/auth/login_screen.dart';
import 'package:logfitness_membership_flutter/features/auth/not_member_screen.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

class _FakeAuth implements MemberAuthRepository {
  _FakeAuth(this.result);

  LoginResult result;
  final List<(String, String)> calls = <(String, String)>[];
  int signOuts = 0;

  /// When set, login() waits for it: lets a test hold a call in flight.
  Completer<void>? gate;

  @override
  Future<LoginResult> login({
    required String identifier,
    required String pin,
  }) async {
    calls.add((identifier, pin));
    await gate?.future;
    return result;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

Future<void> _pump(WidgetTester tester, _FakeAuth auth, {Widget? home}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [memberAuthRepositoryProvider.overrideWithValue(auth)],
      child: MaterialApp(
        theme: appLightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? const LoginScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Types card then PIN; the sixth digit auto-submits after a short beat.
Future<void> _signIn(WidgetTester tester, String id, String pin) async {
  await tester.enterText(find.byKey(loginIdentifierFieldKey), id);
  await tester.enterText(find.byKey(loginPinFieldKey), pin);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

String _pinText(WidgetTester tester) => tester
    .widget<TextField>(find.byKey(loginPinFieldKey))
    .controller!
    .text;

void main() {
  group('loginErrorFor', () {
    test('success has no error', () {
      expect(loginErrorFor(const LoginOk()), isNull);
    });

    test('invalid is the one generic error', () {
      expect(loginErrorFor(const LoginInvalid()), isA<LoginErrorInvalid>());
    });

    test('locked rounds seconds up to whole minutes, minimum one', () {
      expect((loginErrorFor(const LoginLocked(840)) as LoginErrorLocked).minutes, 14);
      expect((loginErrorFor(const LoginLocked(841)) as LoginErrorLocked).minutes, 15);
      expect((loginErrorFor(const LoginLocked(5)) as LoginErrorLocked).minutes, 1);
      expect((loginErrorFor(const LoginLocked(0)) as LoginErrorLocked).minutes, 1);
    });

    test('rate limited and offline and unknown', () {
      expect(loginErrorFor(const LoginRateLimited()), isA<LoginErrorRateLimited>());
      expect(
        loginErrorFor(const LoginFailed(AppFailure(FailureKind.offline, 'x'))),
        isA<LoginErrorOffline>(),
      );
      expect(
        loginErrorFor(const LoginFailed(AppFailure(FailureKind.unknown, 'x'))),
        isA<LoginErrorUnknown>(),
      );
    });

    test('identifier shape: 1-4 digits card, 7-15 phone', () {
      expect(isPlausibleIdentifier('4'), isTrue);
      expect(isPlausibleIdentifier('0004'), isTrue);
      expect(isPlausibleIdentifier('9841234567'), isTrue);
      expect(isPlausibleIdentifier('12345'), isFalse);
      expect(isPlausibleIdentifier('123456'), isFalse);
      expect(isPlausibleIdentifier('1234567890123456'), isFalse);
      expect(isPlausibleIdentifier(''), isFalse);
    });

    test('PIN shape: exactly six digits', () {
      expect(isValidMemberPin('123456'), isTrue);
      expect(isValidMemberPin('12345'), isFalse);
      expect(isValidMemberPin('1234567'), isFalse);
      expect(isValidMemberPin('12345a'), isFalse);
      expect(isValidMemberPin(''), isFalse);
    });
  });

  group('LoginScreen', () {
    testWidgets('PIN input is hardened', (tester) async {
      await _pump(tester, _FakeAuth(const LoginOk()));
      final TextField pin = tester.widget(find.byKey(loginPinFieldKey));
      expect(pin.obscureText, isTrue);
      expect(pin.enableSuggestions, isFalse);
      expect(pin.autocorrect, isFalse);
      expect(pin.autofillHints, isEmpty);
      expect(pin.enableIMEPersonalizedLearning, isFalse);
      expect(pin.keyboardType, TextInputType.number);
      expect(pin.maxLength, 6);
      expect(find.text('Enter the 6-digit PIN from the front desk'), findsOneWidget);
    });

    testWidgets('6th digit with a valid card signs in once, automatically', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '12345');
      await tester.pump(const Duration(milliseconds: 300));
      expect(auth.calls, isEmpty); // five digits is not enough
      await tester.enterText(find.byKey(loginPinFieldKey), '123456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(auth.calls, <(String, String)>[('0004', '123456')]);
    });

    testWidgets('a phone number also auto-submits', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await _signIn(tester, '9841234567', '654321');
      expect(auth.calls, <(String, String)>[('9841234567', '654321')]);
    });

    testWidgets('no auto-submit with an invalid or empty identifier', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginOk());
      await _pump(tester, auth);
      await _signIn(tester, '12345', '123456');
      expect(auth.calls, isEmpty);
      // The reason is shown, and the button stays off.
      expect(find.textContaining('Enter a card number'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byKey(loginSubmitKey)).onPressed,
        isNull,
      );
      // The PIN is kept so the member can fix the card number.
      expect(_pinText(tester), '123456');
    });

    testWidgets('fixing the identifier afterwards does not auto-submit; the button does', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await tester.enterText(find.byKey(loginPinFieldKey), '123456');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.pump(const Duration(milliseconds: 300));
      expect(auth.calls, isEmpty);

      await tester.ensureVisible(find.byKey(loginSubmitKey));
      await tester.tap(find.byKey(loginSubmitKey));
      await tester.pumpAndSettle();
      expect(auth.calls, <(String, String)>[('0004', '123456')]);
    });

    testWidgets('button is off until card and all six digits', (tester) async {
      await _pump(tester, _FakeAuth(const LoginOk()));
      FilledButton button() => tester.widget(find.byKey(loginSubmitKey));
      expect(button().onPressed, isNull);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '1234');
      await tester.pump();
      expect(button().onPressed, isNull);
    });

    testWidgets('no double fire: button tap while the auto call is in flight', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid())..gate = Completer<void>();
      await _pump(tester, auth);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '123456');
      await tester.pump(const Duration(milliseconds: 300));
      expect(auth.calls.length, 1);

      // Busy: the button is disabled and typing again changes nothing.
      expect(
        tester.widget<FilledButton>(find.byKey(loginSubmitKey)).onPressed,
        isNull,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(auth.calls.length, 1);

      auth.gate!.complete();
      await tester.pumpAndSettle();
      expect(auth.calls.length, 1);
    });

    testWidgets('backspace before the timer fires cancels the auto-submit', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginOk());
      await _pump(tester, auth);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '123456');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byKey(loginPinFieldKey), '12345');
      await tester.pump(const Duration(milliseconds: 500));
      expect(auth.calls, isEmpty);
    });

    testWidgets('invalid shows the one generic error and clears all six boxes', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await _signIn(tester, '0004', '123456');

      expect(auth.calls, <(String, String)>[('0004', '123456')]);
      expect(find.text('Card number or PIN is wrong.'), findsOneWidget);
      expect(_pinText(tester), isEmpty);
      expect(find.byKey(const ValueKey<String>('pin-dot')), findsNothing);
    });

    testWidgets('locked shows the wait and clears the PIN', (tester) async {
      await _pump(tester, _FakeAuth(const LoginLocked(14 * 60 + 20)));
      await _signIn(tester, '0004', '123456');

      expect(find.textContaining('Too many tries. Try again in 15 minutes'), findsOneWidget);
      expect(_pinText(tester), isEmpty);
    });

    testWidgets('rate limited and offline have their own copy', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginRateLimited());
      await _pump(tester, auth);
      await _signIn(tester, '0004', '123456');
      expect(find.textContaining('Too many attempts from this phone'), findsOneWidget);

      auth.result = const LoginFailed(AppFailure(FailureKind.offline, 'x'));
      await _signIn(tester, '0004', '123456');
      expect(auth.calls.length, 2);
      expect(find.textContaining('No connection'), findsOneWidget);
    });

    testWidgets('the PIN is not left in the field while the call runs', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid())..gate = Completer<void>();
      await _pump(tester, auth);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '432100');
      await tester.pump(const Duration(milliseconds: 300)); // call in flight
      expect(auth.calls.length, 1);
      expect(_pinText(tester), isEmpty);
      auth.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('after a failure the boxes take focus again', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await _signIn(tester, '0004', '123456');
      final EditableTextState e = tester.state(
        find.descendant(
          of: find.byKey(loginPinFieldKey),
          matching: find.byType(EditableText),
        ),
      );
      expect(e.widget.focusNode.hasFocus, isTrue);
    });

    testWidgets('eye toggle reveals the digits', (tester) async {
      await _pump(tester, _FakeAuth(const LoginOk()));
      await tester.enterText(find.byKey(loginPinFieldKey), '123');
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('pin-dot')), findsNWidgets(3));
      await tester.tap(find.byTooltip('Show PIN'));
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('pin-digit')), findsNWidgets(3));
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('NotMemberScreen', () {
    testWidgets('explains and signs out', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginOk());
      await _pump(tester, auth, home: const NotMemberScreen());
      expect(
        find.text('Your membership is no longer active. Please contact the front desk.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(notMemberSignOutKey));
      await tester.pumpAndSettle();
      expect(auth.signOuts, 1);
    });
  });
}
