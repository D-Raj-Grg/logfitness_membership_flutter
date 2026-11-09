// Shown while the session is restored / claims are resolved (principal is
// loading). Always the brand's dark ground with the white LOG mark, in light
// and dark mode, so it matches the native launch screen (#17181D) and there is
// no colour change at the hand-over from the OS splash.
import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/features/common/log_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Brand.tarRoad,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LogMark(size: 96),
            SizedBox(height: 40),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Brand.elegantGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
