import 'package:flutter/material.dart';

/// The two status hues of the attendance calendar.
///
/// The brand book has no success/danger hues (status elsewhere is carried by
/// icon and weight), but a calendar of green and red days is the one place a
/// member expects them. They stay accessible: a glyph (check / cross) always
/// accompanies the fill, and the glyph-on-fill contrast is >= 4.5:1 in both
/// themes (`attendance_colors_test.dart` asserts it).
class AttendanceColors {
  const AttendanceColors._({
    required this.presentFill,
    required this.onPresent,
    required this.absentFill,
    required this.onAbsent,
  });

  final Color presentFill;
  final Color onPresent;
  final Color absentFill;
  final Color onAbsent;

  /// Deep green / red with white glyphs on the light theme.
  static const AttendanceColors light = AttendanceColors._(
    presentFill: Color(0xFF1B7F3B),
    onPresent: Color(0xFFFFFFFF),
    absentFill: Color(0xFFB3261E),
    onAbsent: Color(0xFFFFFFFF),
  );

  /// Soft green / red with near-black glyphs on the dark theme.
  static const AttendanceColors dark = AttendanceColors._(
    presentFill: Color(0xFF5FD38A),
    onPresent: Color(0xFF0B2615),
    absentFill: Color(0xFFFFB4AB),
    onAbsent: Color(0xFF561E19),
  );

  static AttendanceColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// WCAG contrast ratio between two colours.
  static double contrast(Color a, Color b) {
    final double la = a.computeLuminance();
    final double lb = b.computeLuminance();
    final double hi = la > lb ? la : lb;
    final double lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }
}
