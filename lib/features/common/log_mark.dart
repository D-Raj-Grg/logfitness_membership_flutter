import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// The LOG wordmark, drawn path-for-path from the web console's
/// `logfitness_web/src/app/icon.svg` (viewBox 512, group translated by
/// 110,206): an `L` path, two ring circles (r 36, stroke 28) for `O` and `G`,
/// the `G`'s crossbar, then two cut-outs -- a horizontal slit through the
/// middle band of the whole mark and a notch at the top-right of the `G`.
///
/// Without [withTile] the widget is exactly the mark ([size] is its width, the
/// height follows the 292:100 aspect) on a transparent background. With
/// [withTile] it is the SVG's full square tile (a [Brand.tarRoad] rounded
/// square, corner radius 96/512) and [size] is the side of that square; the
/// mark then sits centred at 292/512 (57%) of the side, as in the SVG.
class LogMark extends StatelessWidget {
  const LogMark({
    super.key,
    required this.size,
    this.color = Brand.white,
    this.withTile = false,
    this.tileColor = Brand.tarRoad,
    this.semanticLabel,
  });

  /// Mark width, or the tile side when [withTile] is true.
  final double size;

  /// Colour of the mark.
  final Color color;

  /// Draw the rounded dark tile behind the mark.
  final bool withTile;

  /// Tile fill; only used when [withTile] is true.
  final Color tileColor;

  /// Announced to screen readers; the mark is decorative when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final double height = withTile
        ? size
        : size * LogMarkGeometry.height / LogMarkGeometry.width;
    final Widget painted = CustomPaint(
      size: Size(size, height),
      painter: LogMarkPainter(
        color: color,
        withTile: withTile,
        tileColor: tileColor,
      ),
    );
    if (semanticLabel == null) {
      return ExcludeSemantics(child: painted);
    }
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(child: painted),
    );
  }
}

/// Dimensions of the mark in SVG user units (the `g` transform's local space).
abstract final class LogMarkGeometry {
  /// Extent of the mark: x 0..292, y 0..100 in the group's local space.
  static const double width = 292;
  static const double height = 100;

  /// The SVG viewBox side and tile corner radius.
  static const double tile = 512;
  static const double tileRadius = 96;

  /// Group translation inside the tile; centres the mark exactly.
  static const double offsetX = 110;
  static const double offsetY = 206;

  /// The mark as one filled path in local (0..292, 0..100) coordinates.
  static Path buildPath() {
    final Path l = Path()
      ..moveTo(0, 0)
      ..lineTo(28, 0)
      ..lineTo(28, 72)
      ..lineTo(62, 72)
      ..lineTo(62, 100)
      ..lineTo(0, 100)
      ..close();
    final Path o = _ring(127, 50);
    final Path g = _ring(242, 50);
    final Path bar = Path()..addRect(const Rect.fromLTWH(229, 38, 61, 25));

    Path mark = l;
    for (final Path p in <Path>[o, g, bar]) {
      mark = Path.combine(ui.PathOperation.union, mark, p);
    }

    // The SVG mask: white rect, minus the slit, minus the G's top-right notch.
    final Path slit = Path()..addRect(const Rect.fromLTWH(-4, 44.5, 300, 11));
    final Path notch = Path()..addRect(const Rect.fromLTWH(253, -10, 45, 48));
    mark = Path.combine(ui.PathOperation.difference, mark, slit);
    mark = Path.combine(ui.PathOperation.difference, mark, notch);
    return mark;
  }

  /// A stroked circle (r 36, stroke 28) as a filled annulus: outer 50, inner 22.
  static Path _ring(double cx, double cy) {
    final Path outer = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: 50));
    final Path inner = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: 22));
    return Path.combine(ui.PathOperation.difference, outer, inner);
  }
}

class LogMarkPainter extends CustomPainter {
  const LogMarkPainter({
    required this.color,
    this.withTile = false,
    this.tileColor = Brand.tarRoad,
  });

  final Color color;
  final bool withTile;
  final Color tileColor;

  static final Path _path = LogMarkGeometry.buildPath();

  /// Paints just the mark so that its 292x100 box fills [target] (uniformly
  /// scaled by width, centred vertically).
  static void paintMark(Canvas canvas, Rect target, Color color) {
    final double scale = target.width / LogMarkGeometry.width;
    final double dy = (target.height - LogMarkGeometry.height * scale) / 2;
    canvas
      ..save()
      ..translate(target.left, target.top + dy)
      ..scale(scale);
    canvas.drawPath(
      _path,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (withTile) {
      final double s = size.width / LogMarkGeometry.tile;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(LogMarkGeometry.tileRadius * s),
        ),
        Paint()..color = tileColor,
      );
      paintMark(
        canvas,
        Rect.fromLTWH(
          LogMarkGeometry.offsetX * s,
          LogMarkGeometry.offsetY * s,
          LogMarkGeometry.width * s,
          LogMarkGeometry.height * s,
        ),
        color,
      );
    } else {
      paintMark(canvas, Offset.zero & size, color);
    }
  }

  @override
  bool shouldRepaint(LogMarkPainter old) =>
      old.color != color ||
      old.withTile != withTile ||
      old.tileColor != tileColor;
}
