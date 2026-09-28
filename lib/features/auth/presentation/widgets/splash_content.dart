import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/l10n.dart';

class SplashContent extends StatelessWidget {
  final String? statusLabel;

  const SplashContent({super.key, this.statusLabel});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Hero(
                  tag: hero_onboarding_logo,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                )
                .animate()
                .fadeIn(duration: 420.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.94, 0.94),
                  end: const Offset(1, 1),
                  duration: 480.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 22),
            const _Tagline()
                .animate()
                .fadeIn(delay: 220.ms, duration: 420.ms)
                .slideY(
                  begin: 0.15,
                  end: 0,
                  duration: 480.ms,
                  curve: Curves.easeOutCubic,
                ),
            const Spacer(flex: 2),
            _ProgressRail(
              label: statusLabel,
            ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();
  static const _baseSize = 22.0;
  static const _lineHeight = 1.5;
  static const _letterSpacing = 1.75;

  static const _lightWeight = FontWeight.w800;
  static const _heavyWeight = FontWeight.w700;

  static const _lightColor = Color.fromARGB(230, 8, 8, 8);
  static const _heavyColor = Color.fromARGB(255, 236, 128, 13);

  TextStyle _light(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontSize: _baseSize,
        height: _lineHeight,
        letterSpacing: _letterSpacing,
        fontWeight: _lightWeight,
        color: _lightColor,
      );

  TextStyle _heavy(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontSize: _baseSize,
        height: _lineHeight,
        letterSpacing: _letterSpacing,
        fontWeight: _heavyWeight,
        color: _heavyColor,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _line(context, light: 'Know Your ', heavy: 'Risk.'),
        _line(context, light: 'Take Action ', heavy: 'Early.'),
        _line(context, light: 'Live ', heavy: 'Better.'),
      ],
    );
  }

  Widget _line(
    BuildContext context, {
    required String light,
    required String heavy,
  }) {
    return Text.rich(
      TextSpan(
        style: _light(context),
        children: [
          TextSpan(text: light),
          TextSpan(text: heavy, style: _heavy(context)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ProgressRail extends StatelessWidget {
  final String? label;
  const _ProgressRail({this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Text(
            label ?? AppLocalizations.getString(context, 'splash.preparing'),
            key: ValueKey(label),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.5,
              letterSpacing: 0.2,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}
