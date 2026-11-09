import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// A tracked-out caps label above a group of content, with an optional
/// trailing action ("See all"). Follows the brand book's label style: small,
/// heavy, wide tracking. Pass the text in its natural case; it is upper-cased
/// here.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: Brand.spaceLg,
        bottom: Brand.spaceSm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
