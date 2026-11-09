import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// A numeral that counts up (or down) to [value] when first shown and
/// whenever [value] changes. Rendered with tabular figures so the width does
/// not wobble. Style defaults to `displayLarge` (the hero numeral). Skips the
/// animation under "reduce motion". Semantics read the final number.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
    this.format,
    super.key,
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  /// Optional formatter (e.g. thousands separators); defaults to `toString`.
  final String Function(int value)? format;

  @override
  Widget build(BuildContext context) {
    final TextStyle effective =
        style ?? Theme.of(context).textTheme.displayLarge!;
    final String Function(int) fmt = format ?? (int v) => '$v';
    final bool still = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: fmt(value),
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.toDouble()),
          duration: still ? Duration.zero : duration,
          curve: Brand.motionCurve,
          builder: (BuildContext context, double v, Widget? _) =>
              Text(fmt(v.round()), style: effective),
        ),
      ),
    );
  }
}
