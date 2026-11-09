import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// How loudly a [StatusPill] speaks. Status is NEVER conveyed by hue alone
/// (brand rule: two colours; accessibility rule: not colour alone), so the
/// levels differ in fill, outline and weight, and every pill carries an icon
/// and words.
///
///  * [strong]   -- solid primary fill, heavy label: "Active", "Booked".
///  * [standard] -- tonal fill + outline: "Expiring", "Waitlisted".
///  * [subtle]   -- outline only, regular weight: "Upcoming", "None".
///  * [alert]    -- error container + 2px error outline: "Expired", "Due".
enum PillEmphasis { strong, standard, subtle, alert }

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.icon,
    this.emphasis = PillEmphasis.standard,
    super.key,
  });

  final String label;
  final IconData icon;
  final PillEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    final (Color bg, Color fg, BorderSide side, FontWeight weight) =
        switch (emphasis) {
      PillEmphasis.strong => (
        s.primary,
        s.onPrimary,
        BorderSide.none,
        FontWeight.w800,
      ),
      PillEmphasis.standard => (
        s.secondaryContainer,
        s.onSecondaryContainer,
        BorderSide(color: s.outline),
        FontWeight.w700,
      ),
      PillEmphasis.subtle => (
        Colors.transparent,
        s.onSurfaceVariant,
        BorderSide(color: s.outlineVariant),
        FontWeight.w500,
      ),
      PillEmphasis.alert => (
        s.errorContainer,
        s.onErrorContainer,
        BorderSide(color: s.error, width: 2),
        FontWeight.w800,
      ),
    };

    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: bg,
            shape: StadiumBorder(side: side),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Brand.spaceMd - 4,
              vertical: Brand.spaceXs + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: Brand.spaceXs + 2),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: weight,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
