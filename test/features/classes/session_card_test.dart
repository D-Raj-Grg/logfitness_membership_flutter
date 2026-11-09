// The card says its state in words and shows capacity as text.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/domain/classes/session_card_state.dart';
import 'package:logfitness_membership_flutter/features/classes/session_card.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

final ClassSession _session = ClassSession(
  id: 's',
  classId: 'c',
  className: 'Morning Yoga',
  startsAt: DateTime.utc(2026, 11, 10, 0, 15),
  endsAt: DateTime.utc(2026, 11, 10, 1, 15),
  capacity: 20,
  bookedCount: 12,
  room: 'Studio 1',
);

Future<void> _pump(
  WidgetTester tester,
  SessionCardState state, {
  Locale locale = const Locale('en'),
  VoidCallback? onBook,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: appLightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SessionCard(
          session: _session,
          state: state,
          timeZone: 'Asia/Kathmandu',
          onBook: onBook ?? () {},
          onCancel: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows time in org timezone, name, capacity text', (t) async {
    await _pump(t, SessionCardState.book);
    expect(find.text('06:00'), findsOneWidget); // 00:15 UTC + 5:45
    expect(find.text('Morning Yoga'), findsOneWidget);
    expect(find.text('12/20'), findsOneWidget);
    expect(find.text('8 spots left'), findsOneWidget);
  });

  testWidgets('each state has its own words', (t) async {
    final Map<SessionCardState, String> expected = <SessionCardState, String>{
      SessionCardState.book: 'Book',
      SessionCardState.joinWaitlist: 'Join waitlist',
      SessionCardState.booked: 'Booked',
      SessionCardState.waitlisted: 'On waitlist',
      SessionCardState.closed: 'Closed',
    };
    for (final MapEntry<SessionCardState, String> e in expected.entries) {
      await _pump(t, e.key);
      expect(find.text(e.value), findsOneWidget, reason: e.key.name);
    }
  });

  testWidgets('book button fires; closed does not', (t) async {
    int taps = 0;
    await _pump(t, SessionCardState.book, onBook: () => taps++);
    await t.tap(find.text('Book'));
    expect(taps, 1);
    await _pump(t, SessionCardState.closed, onBook: () => taps++);
    await t.tap(find.text('Closed'), warnIfMissed: false);
    expect(taps, 1);
  });

  testWidgets('renders in Nepali', (t) async {
    await _pump(t, SessionCardState.book, locale: const Locale('ne'));
    expect(find.text('बुक गर्नुहोस्'), findsOneWidget);
  });
}
