// Raises the screen to full brightness while the check-in code is on screen,
// and gives the user's own level back afterwards. Scanners read a bright code
// far more reliably. Behind an interface so tests (which have no platform
// channel) can swap it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';

abstract class QrBrightness {
  /// Full brightness for this app only (the system setting is untouched).
  Future<void> boost();

  /// Back to whatever the user had.
  Future<void> restore();
}

class PluginQrBrightness implements QrBrightness {
  const PluginQrBrightness();

  // Brightness is cosmetic: a platform that refuses it must never break
  // check-in, so both calls swallow plugin errors.
  @override
  Future<void> boost() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
    } catch (_) {}
  }

  @override
  Future<void> restore() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }
}

final qrBrightnessProvider = Provider<QrBrightness>(
  (ref) => const PluginQrBrightness(),
);
