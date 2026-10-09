import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:my_wellness/common/constants/hero.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Hero(
          tag: HeroTags.authLogo,
          flightShuttleBuilder: (_, __, direction, fromContext, toContext) {
            return direction == HeroFlightDirection.push
                ? toContext.widget
                : fromContext.widget;
          },
          child:
              Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                  )
                  .animate()
                  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                  .moveY(
                    begin: -300,
                    end: 0,
                    duration: 1200.ms,
                    curve: Curves.bounceOut,
                  ),
        ),
      ),
    );
  }
}
