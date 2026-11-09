import 'package:flutter/material.dart';

/// Design tokens for the LOG (Lord of Gyms & Fitness) brand.
///
/// Source of truth is the brand book as implemented in
/// `../logfitness_web/src/app/globals.css`: **two colours, no exceptions** --
/// Tar Road (matte near-black) and Elegant Grey (industrial accent); white is
/// a ground or a reverse, never a third brand colour. That is why this app has
/// no "success green / warning amber": status is carried by icon, weight,
/// fill-vs-outline and words (see `StatusPill`), never by hue.
///
/// Every colour, radius and spacing value used anywhere in the app comes from
/// here or from the [ThemeData] built off it in `theme.dart`. Never hardcode a
/// colour at a call site.
abstract final class Brand {
  // --- Brand colours (hex copied from the web console's globals.css) -------

  /// Tar Road 8245 -- primary base. The web `--tar-road`.
  static const Color tarRoad = Color(0xFF17181D);

  /// The web `--tar-road-elevated`.
  static const Color tarRoadElevated = Color(0xFF1E2026);

  /// Elegant Grey 8232 -- the accent. The web `--elegant-grey`.
  static const Color elegantGrey = Color(0xFF8B9096);

  /// The web `--foreground` on Tar Road (off-white, easier on the eye than
  /// pure white at night).
  static const Color paper = Color(0xFFF4F5F6);

  static const Color white = Color(0xFFFFFFFF);

  /// Elegant Grey darkened until it reads on white at body size (>= 4.5:1).
  /// Elegant Grey itself is 3.2:1 on white, fine for outlines and large
  /// numerals, not for small text.
  static const Color greyInk = Color(0xFF565B62);

  // --- Radii ---------------------------------------------------------------

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 20;

  /// Cards and sheets.
  static const double radiusCard = 24;

  /// Chips, pills, the nav indicator.
  static const double radiusPill = 999;

  // --- Spacing: an 8-pt grid with a 4 half-step ----------------------------

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  /// Horizontal page gutter on every screen.
  static const double gutter = 20;

  /// Minimum height of every button; also the minimum touch target we aim for.
  static const double buttonHeight = 52;

  // --- Motion --------------------------------------------------------------

  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionBase = Duration(milliseconds: 280);
  static const Curve motionCurve = Curves.easeOutCubic;
}
