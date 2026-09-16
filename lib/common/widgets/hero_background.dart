// lib/common/widgets/hero_background.dart
import 'package:flutter/material.dart';
import 'package:my_wellness/common/constatnts/hero.dart';
import 'package:my_wellness/common/res/colors.dart';

class HeroBackground extends StatelessWidget {
  final String asset;
  final double scrimOpacity;
  final Widget? child;

  const HeroBackground({
    super.key,
    this.asset = 'assets/splash.jpg',
    this.scrimOpacity = 0.30,
    this.child,
  });

  /// Preset for the splash screen — no scrim, the logo reads on its own.
  const HeroBackground.splash({super.key, this.child})
      : asset = 'assets/splash.jpg',
        scrimOpacity = 0;

  /// Preset for the intro carousel — light scrim for copy over photo.
  const HeroBackground.intro({super.key, this.child})
      : asset = 'assets/splash.jpg',
        scrimOpacity = 0.35;

  /// Preset for auth pages — stronger scrim so white forms stay legible.
  const HeroBackground.auth({super.key, this.child})
      : asset = 'assets/splash.jpg',
        scrimOpacity = 0.55;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: hero_splash_img,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(color: colorPrimary),
          ),
        ),
        if (scrimOpacity > 0)
          ColoredBox(color: Colors.black.withValues(alpha: scrimOpacity)),
        if (child != null) child!,
      ],
    );
  }
}
