// lib/features/auth/presentation/widgets/splash_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_wellness/common/constants/hero.dart';

class SplashContent extends StatefulWidget {
  const SplashContent({super.key});

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> {
  static const riskColor = Color(0xFF124F5D);
  static const actionColor = Color(0xFFF56E5E);
  static const betterColor = Color(0xFF08B9C1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final logoWidth = (width * 0.58).clamp(190.0, 250.0);
        final headlineSize = (width * 0.105).clamp(28.0, 46.0);

        final headlineStyle = TextStyle(
          fontSize: headlineSize,
          height: 0.94,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.8,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(theme: theme, width: logoWidth),

                const SizedBox(height: 28),

                _buildHeadline(style: headlineStyle),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo({required ThemeData theme, required double width}) {
    // Hero-wrapped, no entry animation — the flight is the animation.
    return Hero(
      tag: hero_onboarding_logo,
      child: Image.asset(
        'assets/images/logo.png',
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.health_and_safety_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          );
        },
      ),
    );
  }

  Widget _buildHeadline({required TextStyle style}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
              'Know Your Risk.',
              textAlign: TextAlign.center,
              style: style.copyWith(color: riskColor),
            )
            .animate()
            .fadeIn(delay: 250.ms, duration: 550.ms, curve: Curves.easeOut)
            .slideX(
              begin: -0.12,
              end: 0,
              delay: 250.ms,
              duration: 650.ms,
              curve: Curves.easeOutCubic,
            ),

        Text(
              'Take Action Early.',
              textAlign: TextAlign.center,
              style: style.copyWith(color: actionColor),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 550.ms, curve: Curves.easeOut)
            .slideX(
              begin: 0.12,
              end: 0,
              delay: 400.ms,
              duration: 650.ms,
              curve: Curves.easeOutCubic,
            ),

        Text(
              'Live Better.',
              textAlign: TextAlign.center,
              style: style.copyWith(color: betterColor),
            )
            .animate()
            .fadeIn(delay: 550.ms, duration: 550.ms, curve: Curves.easeOut)
            .slideY(
              begin: 0.18,
              end: 0,
              delay: 550.ms,
              duration: 650.ms,
              curve: Curves.easeOutCubic,
            )
            .then(delay: 150.ms)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.025, 1.025),
              duration: 250.ms,
              curve: Curves.easeOut,
            )
            .then()
            .scale(
              begin: const Offset(1.025, 1.025),
              end: const Offset(1, 1),
              duration: 300.ms,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}
