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

  @override
  Future<LoginResult> login({
    required String identifier,
    required String pin,
  }) async {
    calls.add((identifier, pin));
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

Future<void> _signIn(WidgetTester tester, String id, String pin) async {
  await tester.enterText(find.byKey(loginIdentifierFieldKey), id);
  await tester.enterText(find.byKey(loginPinFieldKey), pin);
  await tester.pump();
  await tester.ensureVisible(find.byKey(loginSubmitKey));
  await tester.tap(find.byKey(loginSubmitKey));
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

    test('identifier shape: 1-4 digits card, 7+ phone', () {
      expect(isPlausibleIdentifier('4'), isTrue);
      expect(isPlausibleIdentifier('0004'), isTrue);
      expect(isPlausibleIdentifier('98412345678'), isTrue);
      expect(isPlausibleIdentifier('12345'), isFalse);
      expect(isPlausibleIdentifier('123456'), isFalse);
      expect(isPlausibleIdentifier(''), isFalse);
    });
  });

  group('LoginScreen', () {
    testWidgets('PIN field is hardened', (tester) async {
      await _pump(tester, _FakeAuth(const LoginOk()));
      final TextField pin = tester.widget(find.byKey(loginPinFieldKey));
      expect(pin.obscureText, isTrue);
      expect(pin.enableSuggestions, isFalse);
      expect(pin.autocorrect, isFalse);
      expect(pin.autofillHints, isNull);
      expect(pin.keyboardType, TextInputType.number);
      expect(pin.maxLength, 6);
    });

    testWidgets('submit is disabled until card and a 4-digit PIN', (tester) async {
      await _pump(tester, _FakeAuth(const LoginOk()));
      FilledButton button() => tester.widget(find.byKey(loginSubmitKey));
      expect(button().onPressed, isNull);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '123');
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.enterText(find.byKey(loginPinFieldKey), '1234');
      await tester.pump();
      expect(button().onPressed, isNotNull);
    });

    testWidgets('invalid shows the generic error and clears the PIN', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await _signIn(tester, '0004', '1234');

      expect(auth.calls, <(String, String)>[('0004', '1234')]);
      expect(find.text('Card number or PIN is wrong.'), findsOneWidget);
      expect(_pinText(tester), isEmpty);
    });

    testWidgets('locked shows the wait and clears the PIN', (tester) async {
      await _pump(tester, _FakeAuth(const LoginLocked(14 * 60 + 20)));
      await _signIn(tester, '0004', '1234');

      expect(find.textContaining('Too many tries. Try again in 15 minutes'), findsOneWidget);
      expect(_pinText(tester), isEmpty);
    });

    testWidgets('rate limited and offline have their own copy', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginRateLimited());
      await _pump(tester, auth);
      await _signIn(tester, '0004', '1234');
      expect(find.textContaining('Too many attempts from this phone'), findsOneWidget);

      auth.result = const LoginFailed(AppFailure(FailureKind.offline, 'x'));
      await _signIn(tester, '0004', '1234');
      expect(auth.calls.length, 2);
      expect(find.textContaining('No connection'), findsOneWidget);
    });

    testWidgets('an impossible identifier gets the generic error with no call', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginOk());
      await _pump(tester, auth);
      await _signIn(tester, '12345', '1234');

      expect(auth.calls, isEmpty);
      expect(find.text('Card number or PIN is wrong.'), findsOneWidget);
      expect(_pinText(tester), isEmpty);
    });

    testWidgets('the PIN is not left in the field while the call runs', (tester) async {
      final _FakeAuth auth = _FakeAuth(const LoginInvalid());
      await _pump(tester, auth);
      await tester.enterText(find.byKey(loginIdentifierFieldKey), '0004');
      await tester.enterText(find.byKey(loginPinFieldKey), '4321');
      await tester.pump();
      await tester.tap(find.byKey(loginSubmitKey));
      await tester.pump(); // first frame after tap: call in flight
      expect(_pinText(tester), isEmpty);
      await tester.pumpAndSettle();
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
