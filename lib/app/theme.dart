import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// Light and dark Material 3 themes for LOG.
///
/// The [ColorScheme]s are written out role by role instead of generated with
/// `ColorScheme.fromSeed`: a seed would invent a tonal palette (and a hue)
/// that is not in the brand book. Everything here is a step on the Tar Road /
/// Elegant Grey axis, so the surface ladder (lowest .. highest) is a ramp of
/// the same cool grey rather than tinted by an accent.
///
/// Dark mode is the master pairing (white on Tar Road); light mode inverts it
/// -- Tar Road is the ink, white the ground.

const ColorScheme _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Brand.tarRoad,
  onPrimary: Brand.white,
  primaryContainer: Color(0xFFE4E6EA),
  onPrimaryContainer: Brand.tarRoad,
  primaryFixed: Color(0xFFE4E6EA),
  primaryFixedDim: Color(0xFFC9CCD2),
  onPrimaryFixed: Brand.tarRoad,
  onPrimaryFixedVariant: Brand.greyInk,
  secondary: Brand.greyInk,
  onSecondary: Brand.white,
  secondaryContainer: Color(0xFFDADDE2),
  onSecondaryContainer: Brand.tarRoad,
  secondaryFixed: Color(0xFFDADDE2),
  secondaryFixedDim: Brand.elegantGrey,
  onSecondaryFixed: Brand.tarRoad,
  onSecondaryFixedVariant: Brand.greyInk,
  tertiary: Color(0xFF3A3D45),
  onTertiary: Brand.white,
  tertiaryContainer: Color(0xFFEDEEF1),
  onTertiaryContainer: Brand.tarRoad,
  tertiaryFixed: Color(0xFFEDEEF1),
  tertiaryFixedDim: Color(0xFFD3D6DB),
  onTertiaryFixed: Brand.tarRoad,
  onTertiaryFixedVariant: Color(0xFF3A3D45),
  error: Color(0xFFB3261E),
  onError: Brand.white,
  errorContainer: Color(0xFFFBE4E1),
  onErrorContainer: Color(0xFF5C0F0A),
  surface: Color(0xFFF8F9FA),
  onSurface: Brand.tarRoad,
  onSurfaceVariant: Brand.greyInk,
  surfaceDim: Color(0xFFDFE1E5),
  surfaceBright: Brand.white,
  surfaceContainerLowest: Brand.white,
  surfaceContainerLow: Color(0xFFF3F4F6),
  surfaceContainer: Color(0xFFEEEFF2),
  surfaceContainerHigh: Color(0xFFE8EAED),
  surfaceContainerHighest: Color(0xFFE2E4E8),
  outline: Brand.elegantGrey,
  outlineVariant: Color(0xFFD5D8DD),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Brand.tarRoad,
  onInverseSurface: Brand.paper,
  inversePrimary: Brand.paper,
  // M3 tint is applied by surface-tint overlays; transparent keeps cards flat
  // and truthful to the ramp above.
  surfaceTint: Colors.transparent,
);

const ColorScheme _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Brand.paper,
  onPrimary: Brand.tarRoad,
  primaryContainer: Color(0xFF2A2D35),
  onPrimaryContainer: Brand.paper,
  primaryFixed: Color(0xFFE4E6EA),
  primaryFixedDim: Color(0xFFC9CCD2),
  onPrimaryFixed: Brand.tarRoad,
  onPrimaryFixedVariant: Brand.greyInk,
  secondary: Color(0xFFB2B6BC),
  onSecondary: Brand.tarRoad,
  secondaryContainer: Color(0xFF30333B),
  onSecondaryContainer: Brand.paper,
  secondaryFixed: Color(0xFFDADDE2),
  secondaryFixedDim: Brand.elegantGrey,
  onSecondaryFixed: Brand.tarRoad,
  onSecondaryFixedVariant: Brand.greyInk,
  tertiary: Brand.elegantGrey,
  onTertiary: Brand.tarRoad,
  tertiaryContainer: Color(0xFF24262D),
  onTertiaryContainer: Color(0xFFD3D6DB),
  tertiaryFixed: Color(0xFFEDEEF1),
  tertiaryFixedDim: Color(0xFFD3D6DB),
  onTertiaryFixed: Brand.tarRoad,
  onTertiaryFixedVariant: Color(0xFF3A3D45),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF561E19),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Brand.tarRoad,
  onSurface: Brand.paper,
  onSurfaceVariant: Color(0xFFA9ADB3),
  surfaceDim: Color(0xFF121317),
  surfaceBright: Color(0xFF2E3138),
  surfaceContainerLowest: Color(0xFF101114),
  surfaceContainerLow: Color(0xFF1B1C22),
  surfaceContainer: Brand.tarRoadElevated,
  surfaceContainerHigh: Color(0xFF25272E),
  surfaceContainerHighest: Color(0xFF2C2F37),
  outline: Color(0xFF6E737A),
  outlineVariant: Color(0xFF2E3138),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Brand.paper,
  onInverseSurface: Brand.tarRoad,
  inversePrimary: Brand.tarRoad,
  surfaceTint: Colors.transparent,
);

/// Tabular numerals: digits all the same width, so a day count or an amount
/// does not jitter as it counts or changes.
const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

/// Typography. No font is bundled yet (the web uses Anton + Inter; bundling
/// is a later decision), so hierarchy comes from weight, size, tracking and
/// numerals -- all on the platform font.
TextTheme _textTheme(ColorScheme scheme) {
  final Color ink = scheme.onSurface;
  return TextTheme(
    // Hero numerals ("23 days left"): heavy, tight, tabular.
    displayLarge: TextStyle(
      fontSize: 72,
      height: 1,
      fontWeight: FontWeight.w900,
      letterSpacing: -2,
      color: ink,
      fontFeatures: _tabular,
    ),
    displayMedium: TextStyle(
      fontSize: 56,
      height: 1.02,
      fontWeight: FontWeight.w900,
      letterSpacing: -1.5,
      color: ink,
      fontFeatures: _tabular,
    ),
    displaySmall: TextStyle(
      fontSize: 40,
      height: 1.05,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: ink,
      fontFeatures: _tabular,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      color: ink,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      color: ink,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
      color: ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: ink,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
    ),
    // Labels follow the brand book: small, heavy, tracked out. Callers that
    // want the full caps treatment pass `toUpperCase()` text.
    labelLarge: TextStyle(
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: ink,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: scheme.onSurfaceVariant,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: scheme.onSurfaceVariant,
    ),
  );
}

ThemeData _build(ColorScheme scheme) {
  final TextTheme text = _textTheme(scheme);
  final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Brand.radiusLarge),
  );
  const Size buttonMin = Size.fromHeight(Brand.buttonHeight);
  const EdgeInsets buttonPad = EdgeInsets.symmetric(
    horizontal: Brand.spaceLg,
    vertical: Brand.spaceSm,
  );

  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,
    textTheme: text,
    visualDensity: VisualDensity.standard,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    // Flat cards: a hairline outline instead of a shadow.
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radiusCard),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonMin,
        padding: buttonPad,
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: buttonMin,
        padding: buttonPad,
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonMin,
        padding: buttonPad,
        shape: buttonShape,
        textStyle: text.labelLarge,
        side: BorderSide(color: scheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceMd,
        vertical: Brand.spaceMd,
      ),
      border: inputBorder(Colors.transparent),
      enabledBorder: inputBorder(Colors.transparent),
      focusedBorder: inputBorder(scheme.primary, 2),
      errorBorder: inputBorder(scheme.error),
      focusedErrorBorder: inputBorder(scheme.error, 2),
      labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 72,
      // The pill indicator: a filled primary capsule behind the active icon.
      indicatorColor: scheme.primary,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        final bool selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((
        Set<WidgetState> states,
      ) {
        final bool selected = states.contains(WidgetState.selected);
        return text.labelMedium?.copyWith(
          letterSpacing: 0.4,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primary,
      labelStyle: text.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: Brand.spaceSm),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: text.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
      ),
      insetPadding: const EdgeInsets.all(Brand.spaceMd),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: Brand.spaceMd),
      minVerticalPadding: Brand.spaceSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Brand.radiusCard),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radiusCard),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
    ),
  );
}

final ThemeData appLightTheme = _build(_lightScheme);
final ThemeData appDarkTheme = _build(_darkScheme);
