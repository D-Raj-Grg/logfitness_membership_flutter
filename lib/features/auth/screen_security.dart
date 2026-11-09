import 'package:flutter/services.dart';

/// Blocks screenshots / screen recording / the app-switcher thumbnail while a
/// secret is on screen.
///
/// Android: `MainActivity` toggles `WindowManager.LayoutParams.FLAG_SECURE`
/// over this channel. iOS: not implemented -- UIKit has no per-screen
/// equivalent without a secure-text-field overlay trick; the PIN field is
/// `obscureText`, which keeps typed digits out of the snapshot. Recorded in
/// TASKS.md -> Discovered.
abstract final class ScreenSecurity {
  static const MethodChannel _channel = MethodChannel(
    'com.lordofgyms.member/screen_security',
  );

  /// Best effort: a platform without the handler (iOS, tests) is a no-op.
  static Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      // No native side on this platform.
    } on PlatformException {
      // Never block sign-in over a hardening call.
    }
  }
}
