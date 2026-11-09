import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/features/auth/pin_boxes.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key _fieldKey = Key('pin-field');

Future<TextEditingController> _pump(
  WidgetTester tester, {
  bool obscure = true,
  VoidCallback? onCompleted,
  double width = 320,
  bool dark = false,
  double textScale = 1,
}) async {
  final TextEditingController c = TextEditingController();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? appDarkTheme : appLightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: PinBoxes(
              controller: c,
              fieldKey: _fieldKey,
              obscure: obscure,
              onCompleted: onCompleted,
            ),
          ),
        ),
      ),
    ),
  );
  return c;
}

Finder _dots() => find.byKey(const ValueKey<String>('pin-dot'));
Finder _digits() => find.byKey(const ValueKey<String>('pin-digit'));

void main() {
  testWidgets('typing fills boxes left to right and shows dots by default', (
    tester,
  ) async {
    final TextEditingController c = await _pump(tester);
    expect(_dots(), findsNothing);
    await tester.enterText(find.byKey(_fieldKey), '123');
    await tester.pump();
    expect(c.text, '123');
    expect(_dots(), findsNWidgets(3));
    expect(_digits(), findsNothing);
    // No digit is ever put in the tree while obscured.
    expect(find.text('1'), findsNothing);
  });

  testWidgets('obscure false shows the digits', (tester) async {
    await _pump(tester, obscure: false);
    await tester.enterText(find.byKey(_fieldKey), '4096');
    await tester.pump();
    expect(_digits(), findsNWidgets(4));
    expect(find.text('4'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('only digits are accepted and never more than six', (
    tester,
  ) async {
    final TextEditingController c = await _pump(tester);
    await tester.enterText(find.byKey(_fieldKey), '12a-3 4');
    await tester.pump();
    expect(c.text, '1234');
    await tester.enterText(find.byKey(_fieldKey), '12345678');
    await tester.pump();
    expect(c.text, '123456');
    expect(_dots(), findsNWidgets(6));
  });

  testWidgets('pasting six digits fills everything and completes once', (
    tester,
  ) async {
    int completed = 0;
    final TextEditingController c = await _pump(
      tester,
      onCompleted: () => completed++,
    );
    await tester.enterText(find.byKey(_fieldKey), '987654');
    await tester.pump();
    expect(c.text, '987654');
    expect(completed, 1);
    // Editing a full PIN and filling it again fires again; staying full does not.
    await tester.enterText(find.byKey(_fieldKey), '987654');
    await tester.pump();
    expect(completed, 1);
    await tester.enterText(find.byKey(_fieldKey), '98765');
    await tester.pump();
    await tester.enterText(find.byKey(_fieldKey), '987650');
    await tester.pump();
    expect(completed, 2);
  });

  testWidgets('backspace removes the last digit', (tester) async {
    final TextEditingController c = await _pump(tester);
    await tester.enterText(find.byKey(_fieldKey), '123456');
    await tester.pump();
    await tester.enterText(find.byKey(_fieldKey), '12345');
    await tester.pump();
    expect(c.text, '12345');
    expect(_dots(), findsNWidgets(5));
  });

  testWidgets('tapping anywhere on the boxes focuses the input', (
    tester,
  ) async {
    await _pump(tester);
    EditableText editable() => tester.widget(
      find.descendant(
        of: find.byKey(_fieldKey),
        matching: find.byType(EditableText),
      ),
    );
    expect(editable().focusNode.hasFocus, isFalse);
    final Rect r = tester.getRect(find.byKey(_fieldKey));
    await tester.tapAt(r.centerLeft + const Offset(8, 0));
    await tester.pump();
    expect(editable().focusNode.hasFocus, isTrue);
    editable().focusNode.unfocus();
    await tester.pump();
    await tester.tapAt(r.centerRight - const Offset(8, 0));
    await tester.pump();
    expect(editable().focusNode.hasFocus, isTrue);
  });

  testWidgets('the input is a hardened numeric field', (tester) async {
    await _pump(tester);
    final EditableText f = tester.widget(
      find.descendant(
        of: find.byKey(_fieldKey),
        matching: find.byType(EditableText),
      ),
    );
    expect(f.keyboardType, TextInputType.number);
    expect(f.autocorrect, isFalse);
    expect(f.enableSuggestions, isFalse);
    expect(f.enableIMEPersonalizedLearning, isFalse);
    expect(f.autofillHints, isNull);
    // Not a secure field on purpose (iOS secure fields misbehave on delete);
    // the dots are drawn by the boxes and the field text is never shown.
    expect(f.obscureText, isFalse);
    expect(
      f.inputFormatters!
          .whereType<LengthLimitingTextInputFormatter>()
          .single
          .maxLength,
      6,
    );
  });

  testWidgets('screen readers hear the count, never the digits', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(tester, obscure: false);
    await tester.enterText(find.byKey(_fieldKey), '123');
    await tester.pump();
    expect(find.bySemanticsLabel('PIN, 3 of 6 digits entered'), findsOneWidget);
    final SemanticsNode node = tester.getSemantics(
      find.bySemanticsLabel('PIN, 3 of 6 digits entered'),
    );
    expect(node.value, isEmpty);
    expect(node.label.contains('1'), isFalse);
    expect(node.label.contains('2'), isFalse);
    handle.dispose();
  });

  testWidgets('fits a 280 dp wide phone with big text, light and dark', (
    tester,
  ) async {
    for (final bool dark in <bool>[false, true]) {
      await _pump(tester, width: 280, dark: dark, textScale: 2, obscure: false);
      await tester.enterText(find.byKey(_fieldKey), '888888');
      await tester.pump();
      expect(tester.takeException(), isNull);
      final Size size = tester.getSize(find.byType(PinBoxes));
      expect(size.width, 280);
      expect(size.height, greaterThanOrEqualTo(44));
    }
  });

  testWidgets('keyboard formatter list contains digitsOnly', (tester) async {
    await _pump(tester);
    final EditableText f = tester.widget(
      find.descendant(
        of: find.byKey(_fieldKey),
        matching: find.byType(EditableText),
      ),
    );
    expect(
      f.inputFormatters!.whereType<FilteringTextInputFormatter>(),
      isNotEmpty,
    );
  });

  testWidgets('there is no dash and the six boxes are one equal row', (
    tester,
  ) async {
    await _pump(tester);
    final Finder boxes = find.byKey(const ValueKey<String>('pin-empty'));
    expect(boxes, findsNWidgets(6));
    final List<double> tops = <double>[
      for (int i = 0; i < 6; i++) tester.getTopLeft(boxes.at(i)).dy,
    ];
    expect(tops.toSet().length, 1); // all on one line
    // Six equal gaps between neighbouring dots: no wider gap in the middle.
    final List<double> gaps = <double>[
      for (int i = 1; i < 6; i++)
        tester.getTopLeft(boxes.at(i)).dx -
            tester.getTopLeft(boxes.at(i - 1)).dx,
    ];
    for (final double g in gaps) {
      expect(g, closeTo(gaps.first, 0.5));
    }
  });

  testWidgets('deleting one digit at a time empties the boxes one by one', (
    tester,
  ) async {
    final TextEditingController c = await _pump(tester);
    await tester.enterText(find.byKey(_fieldKey), '123456');
    await tester.pump();
    for (int n = 5; n >= 0; n--) {
      await tester.enterText(find.byKey(_fieldKey), '123456'.substring(0, n));
      await tester.pump();
      expect(c.text.length, n);
      expect(_dots(), findsNWidgets(n));
    }
  });
}
