import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';

/// The LOG monogram, built in Flutter (no image asset): a rounded tile in the
/// brand's two colours with the letters set in heavy, tracked-out caps.
class LogMonogram extends StatelessWidget {
  const LogMonogram({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Brand.tarRoad,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(color: Brand.elegantGrey, width: size * 0.03),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Brand.tarRoad.withValues(alpha: 0.25),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.1),
            ),
          ],
        ),
        child: Text(
          'LOG',
          style: TextStyle(
            color: Brand.paper,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w900,
            letterSpacing: size * 0.04,
            height: 1,
          ),
        ),
      ),
    );
  }
}
