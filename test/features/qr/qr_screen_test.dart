import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/qr/qr_token_repository.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/qr/qr_brightness.dart';
import 'package:logfitness_membership_flutter/features/qr/qr_screen.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _FakeRepo implements QrTokenRepository {
  final List<Object> script = <Object>[];
  int mints = 0;

  @override
  Future<QrToken> mint() async {
    mints++;
    if (script.isNotEmpty) {
      // ignore: only_throw_errors
      throw script.removeAt(0);
    }
    return QrToken(token: 'tok-$mints', ttl: const Duration(seconds: 90));
  }
}

class _FakeBrightness implements QrBrightness {
  final List<String> calls = <String>[];

  @override
  Future<void> boost() async => calls.add('boost');

  @override
  Future<void> restore() async => calls.add('restore');
}

const CurrentMember _me = CurrentMember(
  memberId: 'm-1',
  orgId: 'o-1',
  orgName: 'Lord of Gyms',
  currency: 'NPR',
  timezone: 'Asia/Kathmandu',
  homeBranchId: 'b-1',
  homeBranchName: 'Hetauda',
  memberCode: 'LOG-0004',
  fullName: 'Sita Rai',
  phone: '9800000000',
  status: MemberStatus.active,
);

Future<void> _pump(
  WidgetTester tester, {
  required _FakeRepo repo,
  required _FakeBrightness brightness,
  bool tickersEnabled = true,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        qrTokenRepositoryProvider.overrideWithValue(repo),
        qrBrightnessProvider.overrideWithValue(brightness),
        memberSelfProvider.overrideWith((ref) async => _me),
      ],
      child: MaterialApp(
        theme: theme ?? appLightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TickerMode(enabled: tickersEnabled, child: const QrScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows a black-on-white QR with name and member code', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final brightness = _FakeBrightness();
    await _pump(tester, repo: repo, brightness: brightness);

    expect(find.text('Show this at the door'), findsOneWidget);
    expect(find.text('Sita Rai'), findsOneWidget);
    expect(find.text('Member LOG-0004'), findsOneWidget);
    expect(find.text('Refreshes in 90s'), findsOneWidget);

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(find.byKey(const ValueKey('qr-image:tok-1')), findsOneWidget);
    expect(qr.backgroundColor, Colors.white);
    expect(qr.eyeStyle.color, Colors.black);
    expect(qr.dataModuleStyle.color, Colors.black);

    final ticket = tester.widget<Container>(find.byKey(qrTicketKey));
    expect((ticket.decoration! as BoxDecoration).color, Colors.white);

    expect(brightness.calls, <String>['boost']);
    expect(repo.mints, 1);
  });

  testWidgets('QR stays white-on-black in dark mode', (tester) async {
    await _pump(
      tester,
      repo: _FakeRepo(),
      brightness: _FakeBrightness(),
      theme: appDarkTheme,
    );
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.backgroundColor, Colors.white);
    expect(qr.eyeStyle.color, Colors.black);
  });

  testWidgets('offline shows Reconnecting, retries after 10 s, then recovers', (
    tester,
  ) async {
    final repo = _FakeRepo()
      ..script.add(const AppFailure(FailureKind.offline, 'No connection'));
    await _pump(tester, repo: repo, brightness: _FakeBrightness());

    expect(find.byKey(qrReconnectingKey), findsOneWidget);
    expect(find.text('Reconnecting…'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();

    expect(repo.mints, 2);
    expect(find.byKey(qrReconnectingKey), findsNothing);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('a refusal shows the gym text, no QR, and Check again works', (
    tester,
  ) async {
    const reason = 'Your membership expired on 1 Nov. Please renew.';
    final repo = _FakeRepo()
      ..script.add(const AppFailure(FailureKind.refused, reason));
    await _pump(tester, repo: repo, brightness: _FakeBrightness());

    expect(find.byKey(qrNotEligibleKey), findsOneWidget);
    expect(find.text(reason), findsOneWidget);
    expect(find.text("Check-in isn't available right now"), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);

    // No automatic retry loop on a refusal.
    await tester.pump(const Duration(seconds: 60));
    expect(repo.mints, 1);

    await tester.tap(find.byKey(qrCheckAgainKey));
    await tester.pump();
    await tester.pump();
    expect(repo.mints, 2);
    expect(find.byKey(qrNotEligibleKey), findsNothing);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('a hidden tab neither mints nor boosts brightness', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final brightness = _FakeBrightness();
    await _pump(
      tester,
      repo: repo,
      brightness: brightness,
      tickersEnabled: false,
    );
    expect(repo.mints, 0);
    expect(brightness.calls, isEmpty);
  });

  testWidgets('leaving the tab restores brightness and stops refreshing', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final brightness = _FakeBrightness();
    await _pump(tester, repo: repo, brightness: brightness);
    expect(brightness.calls, <String>['boost']);

    // Hide the tab (what the shell does to inactive branches).
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrTokenRepositoryProvider.overrideWithValue(repo),
          qrBrightnessProvider.overrideWithValue(brightness),
          memberSelfProvider.overrideWith((ref) async => _me),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TickerMode(enabled: false, child: QrScreen()),
        ),
      ),
    );
    await tester.pump();
    expect(brightness.calls, <String>['boost', 'restore']);

    await tester.pump(const Duration(minutes: 5));
    expect(repo.mints, 1);
  });

  testWidgets('disposing the screen restores brightness and cancels timers', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final brightness = _FakeBrightness();
    await _pump(tester, repo: repo, brightness: brightness);

    await tester.pumpWidget(const SizedBox());
    expect(brightness.calls, <String>['boost', 'restore']);

    await tester.pump(const Duration(minutes: 5));
    expect(repo.mints, 1);
  });

  testWidgets('app pause restores brightness; resume re-checks the token', (
    tester,
  ) async {
    final repo = _FakeRepo();
    final brightness = _FakeBrightness();
    await _pump(tester, repo: repo, brightness: brightness);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(brightness.calls.last, 'restore');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(brightness.calls.last, 'boost');
    // Real clock: the token is still fresh, so no needless re-mint.
    expect(repo.mints, 1);
  });
}
