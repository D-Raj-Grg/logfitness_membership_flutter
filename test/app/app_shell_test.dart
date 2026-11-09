import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/app.dart';
import 'package:logfitness_membership_flutter/features/common/animated_count.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/supabase/app_claims.dart';
import 'package:logfitness_membership_flutter/supabase/principal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Fixed extends PrincipalController {
  _Fixed(this.value);
  final Principal value;
  @override
  Principal build() => value;
}

Future<void> _pump(WidgetTester tester, Principal p) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [principalProvider.overrideWith(() => _Fixed(p))],
      child: const LogMemberApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a member lands in the shell with five tabs (no Classes)', (tester) async {
    await _pump(
      tester,
      const MemberPrincipal(
        AppClaims(orgId: 'o', branchIds: <String>[], memberId: 'm'),
      ),
    );
    const tabs = ['Home', 'Attendance', 'Check-in', 'Payments', 'Profile'];
    for (final label in tabs) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    // Exactly these five destinations, in this order; Classes is hidden.
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations.map((d) => (d as NavigationDestination).label), tabs);
    expect(find.text('Classes'), findsNothing);

    await tester.tap(find.text('Payments').last);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 3);
  });

  testWidgets('signed out lands on login', (tester) async {
    await _pump(tester, const SignedOut());
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('LOG Fitness'), findsWidgets);
  });

  testWidgets('shared widgets render', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusPill(label: 'Active', icon: Icons.check_circle),
              AnimatedCount(value: 23),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
  });
}
