import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';

class SplashContent extends StatelessWidget {
  final String? statusLabel;

  const SplashContent({super.key, this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.health_and_safety_rounded,
                      size: 88,
                      color: cs.primary,
                    ),
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
            const SizedBox(height: 20),
            Text(
              AppLocalizations.getString(context, 'appName'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: cs.onSurface,
              ),
            ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.getString(context, 'splash.tagline'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ).animate().fadeIn(delay: 220.ms, duration: 420.ms),
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

class _ProgressRail extends StatelessWidget {
  final String? label;
  const _ProgressRail({this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
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
            style: GoogleFonts.inter(
              fontSize: 12.5,
              letterSpacing: 0.2,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
