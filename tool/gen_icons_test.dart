// Generates every raster brand asset from the vector `LogMark` painter.
//
//   flutter test tool/gen_icons_test.dart
//
// It is a test only so that it runs inside the Flutter engine (dart:ui); it
// asserts nothing about the app. Every PNG is drawn straight from the path at
// its final size (no downscaling), so small sizes stay crisp. See
// docs/BRANDING.md for the rules (safe zones, colours).
//
// Outputs (all paths relative to the project root, which is the cwd of
// `flutter test`):
//   assets/brand/log_icon_1024.png               opaque, full-bleed, no alpha
//   assets/brand/log_icon_512.png                same, for the Play listing
//   assets/brand/log_mark_foreground_1024.png    transparent, adaptive layer
//   ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png   opaque RGB
//   ios/Runner/Assets.xcassets/LaunchImage.imageset/*.png transparent mark
//   android/app/src/main/res/mipmap-*/ic_launcher{,_round,_foreground}.png
//   android/app/src/main/res/drawable-*/launch_mark.png   pre-Android-12 splash
//   android/app/src/main/res/drawable-nodpi/splash_icon.png  Android 12+ splash
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/features/common/log_mark.dart';

/// Mark width as a fraction of the icon side on the iOS / store icon. iOS
/// masks the corners itself, so the mark must stay well inside.
const double _iosMarkFraction = 0.58;

/// Mark width as a fraction of the 108dp adaptive-icon layer. The launcher
/// guarantees only the central 66dp circle: a 292x100 mark that is 60.5dp
/// wide has a half-diagonal of ~32dp, inside the 33dp radius.
const double _adaptiveMarkFraction = 0.56;

/// Legacy (pre-Android 8) tile and round icons: the SVG's own proportion.
const double _legacyMarkFraction = 292 / 512;

const String _res = 'android/app/src/main/res';
const String _appIcon = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
const String _launchImage = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';

typedef _Draw = void Function(Canvas canvas, double side);

Future<Uint8List> _render(int w, int h, _Draw draw, {required bool alpha}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  draw(canvas, w.toDouble());
  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(w, h);
  final ByteData data = (await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  ))!;
  image.dispose();
  return encodePng(w, h, data.buffer.asUint8List(), alpha: alpha);
}

/// Full-bleed Tar Road square with the mark centred at [fraction] of the side.
void _fullBleed(Canvas c, double s, double fraction) {
  c.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = Brand.tarRoad);
  final double w = s * fraction;
  LogMarkPainter.paintMark(
    c,
    Rect.fromLTWH((s - w) / 2, (s - w) / 2, w, w),
    Brand.white,
  );
}

/// Transparent canvas with the white mark centred at [fraction] of the side.
void _markOnly(Canvas c, double s, double fraction) {
  final double w = s * fraction;
  LogMarkPainter.paintMark(
    c,
    Rect.fromLTWH((s - w) / 2, (s - w) / 2, w, w),
    Brand.white,
  );
}

void _write(String path, Uint8List bytes) {
  final File f = File(path)..createSync(recursive: true);
  f.writeAsBytesSync(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generate brand rasters', (WidgetTester tester) async {
    await tester.runAsync(() async {
      // --- Masters --------------------------------------------------------
      Future<Uint8List> icon(int px) => _render(
        px,
        px,
        (Canvas c, double s) => _fullBleed(c, s, _iosMarkFraction),
        alpha: false,
      );
      _write('assets/brand/log_icon_1024.png', await icon(1024));
      _write('assets/brand/log_icon_512.png', await icon(512));
      _write(
        'assets/brand/log_mark_foreground_1024.png',
        await _render(
          1024,
          1024,
          (Canvas c, double s) => _markOnly(c, s, _adaptiveMarkFraction),
          alpha: true,
        ),
      );

      // --- iOS app icon: every file the Contents.json lists ----------------
      final RegExp name = RegExp(r'^Icon-App-([\d.]+)x[\d.]+@(\d)x\.png$');
      for (final FileSystemEntity e in Directory(_appIcon).listSync()) {
        final Match? m = name.firstMatch(e.uri.pathSegments.last);
        if (m == null) {
          continue;
        }
        final int px = (double.parse(m.group(1)!) * int.parse(m.group(2)!))
            .round();
        _write(e.path, await icon(px));
      }

      // --- iOS launch image: white mark, transparent, 96pt wide ------------
      for (final int scale in <int>[1, 2, 3]) {
        final int w = 96 * scale;
        final int h = 33 * scale;
        final String file = scale == 1
            ? 'LaunchImage.png'
            : 'LaunchImage@${scale}x.png';
        _write(
          '$_launchImage/$file',
          await _render(
            w,
            h,
            (Canvas c, double s) => LogMarkPainter.paintMark(
              c,
              Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
              Brand.white,
            ),
            alpha: true,
          ),
        );
      }

      // --- Android launcher icons -----------------------------------------
      const Map<String, double> density = <String, double>{
        'mdpi': 1,
        'hdpi': 1.5,
        'xhdpi': 2,
        'xxhdpi': 3,
        'xxxhdpi': 4,
      };
      for (final MapEntry<String, double> d in density.entries) {
        final int legacy = (48 * d.value).round();
        final int layer = (108 * d.value).round();
        final String dir = '$_res/mipmap-${d.key}';
        // Legacy rounded-square icon.
        _write(
          '$dir/ic_launcher.png',
          await _render(legacy, legacy, (Canvas c, double s) {
            final RRect tile = RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, s, s),
              Radius.circular(s * 96 / 512),
            );
            c.drawRRect(tile, Paint()..color = Brand.tarRoad);
            final double w = s * _legacyMarkFraction;
            LogMarkPainter.paintMark(
              c,
              Rect.fromLTWH((s - w) / 2, (s - w) / 2, w, w),
              Brand.white,
            );
          }, alpha: true),
        );
        // Legacy round icon.
        _write(
          '$dir/ic_launcher_round.png',
          await _render(legacy, legacy, (Canvas c, double s) {
            c.drawCircle(
              Offset(s / 2, s / 2),
              s / 2,
              Paint()..color = Brand.tarRoad,
            );
            final double w = s * _legacyMarkFraction;
            LogMarkPainter.paintMark(
              c,
              Rect.fromLTWH((s - w) / 2, (s - w) / 2, w, w),
              Brand.white,
            );
          }, alpha: true),
        );
        // Adaptive foreground (also the monochrome layer).
        _write(
          '$dir/ic_launcher_foreground.png',
          await _render(
            layer,
            layer,
            (Canvas c, double s) => _markOnly(c, s, _adaptiveMarkFraction),
            alpha: true,
          ),
        );
        // Pre-Android-12 splash: the mark alone, 96dp wide.
        final int lw = (96 * d.value).round();
        final int lh = (33 * d.value).round();
        _write(
          '$_res/drawable-${d.key}/launch_mark.png',
          await _render(
            lw,
            lh,
            (Canvas c, double s) => LogMarkPainter.paintMark(
              c,
              Rect.fromLTWH(0, 0, lw.toDouble(), lh.toDouble()),
              Brand.white,
            ),
            alpha: true,
          ),
        );
      }

      // --- Android 12+ splash icon: same proportions as the adaptive layer
      // (the system shows it in a circle ~67% of the canvas), at a size that
      // stays sharp on xxxhdpi (288dp canvas).
      _write(
        '$_res/drawable-nodpi/splash_icon.png',
        await _render(
          1152,
          1152,
          (Canvas c, double s) => _markOnly(c, s, _adaptiveMarkFraction),
          alpha: true,
        ),
      );
    });
  });
}

// --- Minimal PNG encoder (dart:ui only encodes RGBA; App Store icons must
// have no alpha channel at all, so we write colour type 2 ourselves). -------

Uint8List encodePng(int w, int h, Uint8List rgba, {required bool alpha}) {
  final int channels = alpha ? 4 : 3;
  final Uint8List raw = Uint8List((w * channels + 1) * h);
  int o = 0;
  for (int y = 0; y < h; y++) {
    raw[o++] = 0; // filter: none
    for (int x = 0; x < w; x++) {
      final int i = (y * w + x) * 4;
      raw[o++] = rgba[i];
      raw[o++] = rgba[i + 1];
      raw[o++] = rgba[i + 2];
      if (alpha) {
        raw[o++] = rgba[i + 3];
      }
    }
  }
  final BytesBuilder out = BytesBuilder();
  out.add(<int>[137, 80, 78, 71, 13, 10, 26, 10]);
  final ByteData ihdr = ByteData(13)
    ..setUint32(0, w)
    ..setUint32(4, h)
    ..setUint8(8, 8)
    ..setUint8(9, alpha ? 6 : 2);
  _chunk(out, 'IHDR', ihdr.buffer.asUint8List());
  _chunk(out, 'IDAT', Uint8List.fromList(zlib.encode(raw)));
  _chunk(out, 'IEND', Uint8List(0));
  return out.toBytes();
}

void _chunk(BytesBuilder out, String type, Uint8List data) {
  final List<int> t = type.codeUnits;
  final ByteData len = ByteData(4)..setUint32(0, data.length);
  out.add(len.buffer.asUint8List());
  out.add(t);
  out.add(data);
  final ByteData crc = ByteData(4)..setUint32(0, _crc32(<int>[...t, ...data]));
  out.add(crc.buffer.asUint8List());
}

final List<int> _crcTable = List<int>.generate(256, (int n) {
  int c = n;
  for (int k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  int c = 0xFFFFFFFF;
  for (final int b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}
