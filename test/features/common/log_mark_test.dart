import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:logfitness_membership_flutter/features/common/log_mark.dart';

void main() {
  testWidgets('LogMark renders at several sizes, with and without tile', (
    tester,
  ) async {
    for (final double size in <double>[16, 64, 96, 320]) {
      for (final bool tile in <bool>[false, true]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: LogMark(size: size, withTile: tile)),
          ),
        );
        expect(tester.takeException(), isNull);
        final Size rendered = tester.getSize(find.byType(LogMark));
        expect(rendered.width, size);
        expect(rendered.height, tile ? size : closeTo(size * 100 / 292, 0.001));
      }
    }
  });

  test('mark path has the slit and the G notch cut out', () {
    final Path p = LogMarkGeometry.buildPath();
    // Solid: stem of the L, left side of the O ring.
    expect(p.contains(const Offset(14, 30)), isTrue);
    expect(p.contains(const Offset(92, 30)), isTrue);
    // Slit: the middle band is empty through the L stem and the O ring.
    expect(p.contains(const Offset(14, 50)), isFalse);
    expect(p.contains(const Offset(92, 50)), isFalse);
    // Notch: top-right of the G is removed, top-left of the G is not.
    expect(p.contains(const Offset(280, 20)), isFalse);
    expect(p.contains(const Offset(215, 30)), isTrue);
    // Hole of the O.
    expect(p.contains(const Offset(127, 30)), isFalse);
  });

  testWidgets('LogMark exposes a semantic label only when asked', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: LogMark(size: 64, semanticLabel: 'LOG'),
      ),
    );
    expect(find.bySemanticsLabel('LOG'), findsOneWidget);
  });
}
