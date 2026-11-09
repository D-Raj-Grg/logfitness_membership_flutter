import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// The app's one card surface: rounded (24), flat, hairline-outlined.
///
/// Three looks, all on the Tar Road / Elegant Grey axis:
///  * default -- `surfaceContainerLow` with an outline;
///  * [LogCardTone.tonal] -- a quieter, outline-free fill for nested content;
///  * [LogCardTone.inverse] -- the master pairing (white on Tar Road in light
///    mode, the reverse in dark). Use once per screen for the hero card.
/// Set [gradient] to override the fill with a (subtle, same-family) gradient.
/// Pass [onTap] to make the whole surface a ripple target.
enum LogCardTone { surface, tonal, inverse }

class LogCard extends StatelessWidget {
  const LogCard({
    required this.child,
    this.tone = LogCardTone.surface,
    this.gradient,
    this.padding = const EdgeInsets.all(Brand.spaceLg),
    this.onTap,
    super.key,
  });

  final Widget child;
  final LogCardTone tone;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (Color fill, Color? border) = switch (tone) {
      LogCardTone.surface => (scheme.surfaceContainerLow, scheme.outlineVariant),
      LogCardTone.tonal => (scheme.surfaceContainerHigh, null),
      LogCardTone.inverse => (scheme.inverseSurface, null),
    };
    final BorderRadius radius = BorderRadius.circular(Brand.radiusCard);

    // Descendants (text, icons) of an inverse card read `onInverseSurface`.
    final Widget content = tone == LogCardTone.inverse
        ? DefaultTextStyle.merge(
            style: TextStyle(color: scheme.onInverseSurface),
            child: IconTheme.merge(
              data: IconThemeData(color: scheme.onInverseSurface),
              child: Padding(padding: padding, child: child),
            ),
          )
        : Padding(padding: padding, child: child);

    return Material(
      color: gradient == null ? fill : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: border == null ? BorderSide.none : BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: gradient == null ? null : BoxDecoration(gradient: gradient),
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
