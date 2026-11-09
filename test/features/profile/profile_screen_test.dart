import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/locale_controller.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/app/theme_mode_controller.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/member/my_card.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/features/profile/profile_screen.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuth implements MemberAuthRepository {
  int signOuts = 0;

  @override
  Future<LoginResult> login({
    required String identifier,
    required String pin,
  }) async => const LoginOk();

  @override
  Future<void> signOut() async => signOuts++;
}

const CurrentMember _me = CurrentMember(
  memberId: 'm1',
  orgId: 'o1',
  orgName: 'Lord of Gyms Fitness',
  currency: 'NPR',
  timezone: 'Asia/Kathmandu',
  homeBranchId: 'b1',
  homeBranchName: 'Hetauda',
  memberCode: 'M-001',
  fullName: 'Sita Devi Sharma',
  phone: '9841000000',
  status: MemberStatus.active,
);

class _Harness {
  _Harness(this.container, this.auth);

  final ProviderContainer container;
  final _FakeAuth auth;
}

Future<_Harness> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final _FakeAuth auth = _FakeAuth();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      sessionProvider.overrideWithValue(null),
      memberAuthRepositoryProvider.overrideWithValue(auth),
      memberSelfProvider.overrideWith((ref) async => _me),
      myCardProvider.overrideWith(
        (ref) async => const MyCard(cardNo: 4, cardNoText: '0004'),
      ),
      appVersionProvider.overrideWith((ref) async => '1.0.0 (7)'),
    ],
  );
  addTearDown(container.dispose);
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          theme: appLightTheme,
          locale: ref.watch(localeProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(container, auth);
}

void main() {
  test('initialsOf', () {
    expect(initialsOf('Sita Devi Sharma'), 'SS');
    expect(initialsOf('Sita'), 'S');
    expect(initialsOf('  '), '?');
    expect(initialsOf('sita sharma'), 'SS');
  });

  testWidgets('shows the member read-only details', (tester) async {
    await _pump(tester);
    expect(find.text('Sita Devi Sharma'), findsOneWidget);
    expect(find.text('SS'), findsOneWidget);
    expect(find.text('M-001'), findsOneWidget);
    expect(find.text('NO. 0004'), findsOneWidget);
    expect(find.text('Hetauda'), findsOneWidget);
    expect(find.text('9841000000'), findsOneWidget);
    expect(find.text('1.0.0 (7)'), findsOneWidget);
  });

  testWidgets('sign out asks first; cancel does nothing', (tester) async {
    final _Harness h = await _pump(tester);
    await tester.ensureVisible(find.byKey(profileSignOutKey));
    await tester.tap(find.byKey(profileSignOutKey));
    await tester.pumpAndSettle();
    expect(find.text('Sign out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(h.auth.signOuts, 0);
  });

  testWidgets('confirming sign out calls the repository once', (tester) async {
    final _Harness h = await _pump(tester);
    await tester.ensureVisible(find.byKey(profileSignOutKey));
    await tester.tap(find.byKey(profileSignOutKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(profileSignOutConfirmKey));
    await tester.pumpAndSettle();
    expect(h.auth.signOuts, 1);
  });

  testWidgets('language switch changes the app locale to Nepali', (tester) async {
    final _Harness h = await _pump(tester);
    await tester.ensureVisible(find.byKey(profileLanguageKey));
    await tester.tap(find.text('नेपाली'));
    await tester.pumpAndSettle();
    expect(h.container.read(localeProvider), const Locale('ne'));
    expect(find.text('प्रोफाइल'), findsOneWidget);
  });

  testWidgets('theme switch updates the theme mode', (tester) async {
    final _Harness h = await _pump(tester);
    await tester.ensureVisible(find.byKey(profileThemeKey));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(h.container.read(themeModeProvider), ThemeMode.dark);
  });
}
