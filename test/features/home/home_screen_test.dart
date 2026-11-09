
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/attendance/membership_snapshot.dart';
import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/my_card.dart';
import 'package:logfitness_membership_flutter/data/renewal/renewal_repository.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/home/home_providers.dart';
import 'package:logfitness_membership_flutter/features/home/home_screen.dart';
import 'package:logfitness_membership_flutter/features/home/renewal_sheet.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

const CurrentMember _me = CurrentMember(
  memberId: 'm1',
  orgId: 'o1',
  orgName: 'Lord of Gyms Fitness',
  currency: 'NPR',
  timezone: 'Asia/Kathmandu',
  homeBranchId: 'b1',
  homeBranchName: 'Hetauda',
  memberCode: 'M-001',
  fullName: 'Sita Sharma',
  phone: '9841000000',
  status: MemberStatus.active,
);

HomeData _data(
  MembershipSnapshot snap, {
  MyCard card = const MyCard(cardNo: 4, cardNoText: '0004'),
}) => HomeData(
  member: _me,
  snapshot: snap,
  card: card,
  fetchedAt: DateTime.now(),
);

class _FakeRenewal implements RenewalRepository {
  _FakeRenewal(this.result);

  Object result; // RenewalResult or an Object to throw
  final List<(String?, String?)> calls = <(String?, String?)>[];

  @override
  Future<RenewalResult> requestRenewal({String? phone, String? note}) async {
    calls.add((phone, note));
    final Object r = result;
    if (r is RenewalResult) {
      return r;
    }
    throw r;
  }
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required AsyncValue<HomeData> home,
  _FakeRenewal? renewal,
}) async {
  final ProviderContainer container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      sessionProvider.overrideWithValue(null),
      homeDataProvider.overrideWith((ref) async {
        final HomeData? v = home.value;
        if (v != null) {
          return v;
        }
        throw home.error!;
      }),
      renewalRepositoryProvider.overrideWithValue(
        renewal ?? _FakeRenewal(RenewalResult.ok),
      ),
    ],
  );
  addTearDown(container.dispose);
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appLightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('active: big numeral, plan, card chip, no due row', (tester) async {
    await _pump(
      tester,
      home: AsyncData(
        _data(
          MembershipSnapshot(
            banner: SnapshotBanner.active,
            planName: 'Monthly',
            daysToExpiry: 21,
            endDate: DateTime.utc(2026, 12, 1),
          ),
        ),
      ),
    );
    expect(find.text('Hi, Sita'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('days left'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('01 Dec 2026'), findsOneWidget);
    expect(find.text('NO. 0004'), findsOneWidget);
    expect(find.byKey(homeAmountDueKey), findsNothing);
  });

  testWidgets('1 day uses the singular label', (tester) async {
    await _pump(
      tester,
      home: AsyncData(
        HomeData(
          member: _me,
          snapshot: const MembershipSnapshot(
            banner: SnapshotBanner.expiring,
            daysToExpiry: 1,
          ),
          card: const MyCard.none(),
          fetchedAt: _epoch,
        ),
      ),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('day left'), findsOneWidget);
    expect(find.text('Expiring soon'), findsOneWidget);
    // Hidden gracefully with no card.
    expect(find.byKey(homeCardChipKey), findsNothing);
  });

  testWidgets('expired shows "Expired N days ago" and dues in rupees', (tester) async {
    await _pump(
      tester,
      home: AsyncData(
        _data(
          const MembershipSnapshot(
            banner: SnapshotBanner.expired,
            daysToExpiry: -9,
            duePaisa: 150050,
          ),
        ),
      ),
    );
    expect(find.text('Expired'), findsWidgets);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('days ago'), findsOneWidget);
    expect(find.byKey(homeAmountDueKey), findsOneWidget);
    expect(find.text('NPR 1,500.5'), findsOneWidget);
  });

  testWidgets('frozen and none read as words, not numbers', (tester) async {
    await _pump(
      tester,
      home: AsyncData(_data(const MembershipSnapshot(banner: SnapshotBanner.frozen))),
    );
    expect(find.text('Frozen'), findsWidgets);
    expect(find.text('No active plan'), findsNothing);
  });

  testWidgets('failure with nothing cached shows the retry view', (tester) async {
    await _pump(
      tester,
      home: const AsyncError(
        AppFailure(FailureKind.offline, 'No connection.'),
        StackTrace.empty,
      ),
    );
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  group('renewal', () {
    final HomeData data = _data(
      const MembershipSnapshot(banner: SnapshotBanner.expiring, daysToExpiry: 2),
    );

    Future<void> request(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(homeRenewButtonKey));
      await tester.tap(find.byKey(homeRenewButtonKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(renewalPhoneFieldKey), '9841111111');
      await tester.enterText(find.byKey(renewalNoteFieldKey), 'call after 5');
      await tester.tap(find.byKey(renewalSendKey));
      await tester.pumpAndSettle();
    }

    testWidgets('ok -> pending state, button disabled', (tester) async {
      final _FakeRenewal repo = _FakeRenewal(RenewalResult.ok);
      await _pump(tester, home: AsyncData(data), renewal: repo);
      await request(tester);

      expect(repo.calls, <(String?, String?)>[('9841111111', 'call after 5')]);
      expect(
        find.text('Requested just now. The front desk will call you.'),
        findsOneWidget,
      );
      expect(find.text('Request sent'), findsOneWidget);
      final FilledButton b = tester.widget(
        find.byKey(homeRenewButtonKey),
      );
      expect(b.onPressed, isNull);
    });

    testWidgets('too_soon is explained and stays pending', (tester) async {
      await _pump(
        tester,
        home: AsyncData(data),
        renewal: _FakeRenewal(RenewalResult.tooSoon),
      );
      await request(tester);
      expect(find.textContaining('You asked a moment ago'), findsOneWidget);
      expect(find.byKey(homeRenewPendingKey), findsOneWidget);
    });

    testWidgets('offline failure shows a snackbar and leaves the button usable', (tester) async {
      await _pump(
        tester,
        home: AsyncData(data),
        renewal: _FakeRenewal(
          const AppFailure(FailureKind.offline, 'No connection, try again.'),
        ),
      );
      await request(tester);
      expect(find.text('No connection, try again.'), findsOneWidget);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNotNull);
      expect(find.byKey(homeRenewPendingKey), findsNothing);
    });

    testWidgets('an empty sheet still sends (both fields are optional)', (tester) async {
      final _FakeRenewal repo = _FakeRenewal(RenewalResult.ok);
      await _pump(tester, home: AsyncData(data), renewal: repo);
      await tester.ensureVisible(find.byKey(homeRenewButtonKey));
      await tester.tap(find.byKey(homeRenewButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(renewalSendKey));
      await tester.pumpAndSettle();
      expect(repo.calls.single, ('', ''));
    });
  });

  test('RenewalController: state machine with a fake repository', () async {
    final _FakeRenewal repo = _FakeRenewal(RenewalResult.noMember);
    final ProviderContainer c = ProviderContainer(
      overrides: [
        sessionProvider.overrideWithValue(null),
        renewalRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    final RenewalController ctl = c.read(renewalControllerProvider.notifier);

    expect(await ctl.submit(), RenewalOutcome.noMember);
    expect(c.read(renewalControllerProvider), isA<RenewalIdle>());

    repo.result = const AppFailure(FailureKind.offline, 'x');
    await expectLater(ctl.submit(), throwsA(isA<AppFailure>()));
    expect(c.read(renewalControllerProvider), isA<RenewalIdle>());

    repo.result = RenewalResult.ok;
    expect(await ctl.submit(), RenewalOutcome.requested);
    expect(c.read(renewalControllerProvider), isA<RenewalRequested>());

    repo.result = RenewalResult.tooSoon;
    expect(await ctl.submit(), RenewalOutcome.tooSoon);
    expect(c.read(renewalControllerProvider), isA<RenewalRequested>());
  });

  test('RenewalResult.parse maps the RPC strings', () {
    expect(RenewalResult.parse('ok'), RenewalResult.ok);
    expect(RenewalResult.parse('too_soon'), RenewalResult.tooSoon);
    expect(RenewalResult.parse('no_member'), RenewalResult.noMember);
    expect(RenewalResult.parse('wat'), isNull);
    expect(RenewalResult.parse(null), isNull);
  });

  test('MyCard.fromJson tolerates a member with no card', () {
    final MyCard none = MyCard.fromJson(<String, dynamic>{
      'card_no': null,
      'card_no_text': null,
      'assigned_at': null,
    });
    expect(none.hasCard, isFalse);
    final MyCard has = MyCard.fromJson(<String, dynamic>{
      'card_no': 4,
      'card_no_text': '0004',
      'assigned_at': '2026-11-01T10:00:00Z',
    });
    expect(has.cardNoText, '0004');
    expect(has.assignedAt, isNotNull);
  });
}

final DateTime _epoch = DateTime.utc(2026, 11, 9);
