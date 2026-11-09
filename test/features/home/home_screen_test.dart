
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
  _FakeRenewal(this.result, {this.pending});

  Object result; // RenewalResult or an Object to throw
  PendingRenewal? pending;

  /// Set to make `pendingRequest()` fail (an AppFailure or any error).
  Object? pendingError;
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

  @override
  Future<PendingRenewal?> pendingRequest() async {
    final Object? e = pendingError;
    if (e != null) {
      throw e;
    }
    return pending;
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

  testWidgets('expired reads "Expired" once, then "9 days ago", plus dues', (tester) async {
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
    // The pill carries the word; the headline must not repeat it.
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('days ago'), findsOneWidget);
    expect(find.byKey(homeAmountDueKey), findsOneWidget);
    expect(find.text('NPR 1,500.5'), findsOneWidget);
  });

  testWidgets('expired a day ago uses the singular label', (tester) async {
    await _pump(
      tester,
      home: AsyncData(
        _data(
          const MembershipSnapshot(
            banner: SnapshotBanner.expired,
            daysToExpiry: -1,
          ),
        ),
      ),
    );
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('day ago'), findsOneWidget);
  });

  testWidgets('expired with no day count says "Membership ended", not "Expired" twice', (
    tester,
  ) async {
    await _pump(
      tester,
      home: AsyncData(
        _data(const MembershipSnapshot(banner: SnapshotBanner.expired)),
      ),
    );
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Membership ended'), findsOneWidget);
  });

  testWidgets('a live banner with negative days shows an Expired pill, not Active', (
    tester,
  ) async {
    await _pump(
      tester,
      home: AsyncData(
        _data(
          const MembershipSnapshot(banner: SnapshotBanner.active, daysToExpiry: -3),
        ),
      ),
    );
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('days ago'), findsOneWidget);
  });

  testWidgets('the My bookings tile is hidden while classes are off', (tester) async {
    await _pump(
      tester,
      home: AsyncData(
        _data(const MembershipSnapshot(banner: SnapshotBanner.active, daysToExpiry: 5)),
      ),
    );
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('My bookings'), findsNothing);
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
    }

    testWidgets('one tap sends the member phone with no note and no sheet', (tester) async {
      final _FakeRenewal repo = _FakeRenewal(RenewalResult.ok);
      await _pump(tester, home: AsyncData(data), renewal: repo);
      await request(tester);

      expect(repo.calls, <(String?, String?)>[('9841000000', null)]);
      // No sheet/dialog was opened.
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(
        find.text('Requested just now. The front desk will call you.'),
        findsOneWidget,
      );
      expect(find.text('Request sent. The front desk will call you.'), findsOneWidget);
      expect(find.text('Request sent'), findsOneWidget);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNull);
    });

    testWidgets('too_soon is explained and stays pending, not an error', (tester) async {
      await _pump(
        tester,
        home: AsyncData(data),
        renewal: _FakeRenewal(RenewalResult.tooSoon),
      );
      await request(tester);
      expect(find.textContaining('You asked a moment ago'), findsOneWidget);
      expect(find.byKey(homeRenewPendingKey), findsOneWidget);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNull);
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

    testWidgets('no_member is reported and the button stays usable', (tester) async {
      await _pump(
        tester,
        home: AsyncData(data),
        renewal: _FakeRenewal(RenewalResult.noMember),
      );
      await request(tester);
      expect(find.textContaining("couldn't find an active membership"), findsOneWidget);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNotNull);
    });

    testWidgets('a pending request from the server is shown and disables the button', (
      tester,
    ) async {
      final DateTime at = DateTime.now().subtract(const Duration(minutes: 30));
      final _FakeRenewal repo = _FakeRenewal(
        RenewalResult.ok,
        pending: PendingRenewal(
          requestedAt: at.subtract(const Duration(hours: 1)),
          lastRequestedAt: at,
          requestCount: 2,
        ),
      );
      await _pump(tester, home: AsyncData(data), renewal: repo);
      await tester.ensureVisible(find.byKey(homeRenewButtonKey));

      expect(find.byKey(homeRenewPendingKey), findsOneWidget);
      expect(find.textContaining('The front desk will call you.'), findsOneWidget);
      expect(find.text('Request sent'), findsOneWidget);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNull);
      expect(repo.calls, isEmpty);
    });

    testWidgets('a pending request from an earlier day names the date', (tester) async {
      final _FakeRenewal repo = _FakeRenewal(
        RenewalResult.ok,
        pending: PendingRenewal(
          requestedAt: DateTime.utc(2026, 1, 2, 10),
          lastRequestedAt: DateTime.utc(2026, 1, 3, 10),
          requestCount: 1,
        ),
      );
      await _pump(tester, home: AsyncData(data), renewal: repo);
      expect(find.textContaining('03 Jan 2026'), findsOneWidget);
    });

    testWidgets('pendingRequest failing does not break Home; the button is usable', (
      tester,
    ) async {
      final _FakeRenewal repo = _FakeRenewal(RenewalResult.ok)
        ..pendingError = const AppFailure(FailureKind.offline, 'No connection.');
      await _pump(tester, home: AsyncData(data), renewal: repo);

      expect(find.text('Hi, Sita'), findsOneWidget);
      expect(find.byKey(homeRenewPendingKey), findsNothing);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNotNull);
    });

    testWidgets('a refresh frees the button once the request is handled', (
      tester,
    ) async {
      final _FakeRenewal repo = _FakeRenewal(
        RenewalResult.ok,
        pending: PendingRenewal(
          requestedAt: DateTime.now(),
          lastRequestedAt: DateTime.now(),
          requestCount: 1,
        ),
      );
      final ProviderContainer c = await _pump(tester, home: AsyncData(data), renewal: repo);
      expect(find.byKey(homeRenewPendingKey), findsOneWidget);

      repo.pending = null; // the front desk handled it
      c.invalidate(pendingRenewalProvider);
      await tester.pumpAndSettle();

      expect(find.byKey(homeRenewPendingKey), findsNothing);
      final FilledButton b = tester.widget(find.byKey(homeRenewButtonKey));
      expect(b.onPressed, isNotNull);
    });
  });

  test('PendingRenewal.tryParse follows the RPC contract', () {
    final PendingRenewal? p = PendingRenewal.tryParse(<String, dynamic>{
      'status': 'pending',
      'requested_at': '2026-11-09T04:00:00Z',
      'last_requested_at': '2026-11-09T05:30:00Z',
      'request_count': 3,
    });
    expect(p, isNotNull);
    expect(p!.requestedAt, DateTime.utc(2026, 11, 9, 4));
    expect(p.lastRequestedAt, DateTime.utc(2026, 11, 9, 5, 30));
    expect(p.requestCount, 3);
    expect(PendingRenewal.tryParse(null), isNull);
    expect(PendingRenewal.tryParse(<String, dynamic>{'status': 'handled'}), isNull);
    // last_requested_at missing: falls back to requested_at.
    expect(
      PendingRenewal.tryParse(<String, dynamic>{
        'status': 'pending',
        'requested_at': '2026-11-09T04:00:00Z',
      })!.lastRequestedAt,
      DateTime.utc(2026, 11, 9, 4),
    );
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
