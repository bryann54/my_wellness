
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/auth/data/models/onboarding_page_model.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/on_boarding_title.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/orbiting_illustration.dart';

class OnboardingView extends StatelessWidget {
  final OnboardingPageModel pageData;
  final int pageIndex;

  const OnboardingView({
    required this.pageData,
    required this.pageIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: hero_onboarding_logo,
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: OnboardingTitle(
                  key: ValueKey(pageData.titleKey),
                  title: AppLocalizations.getString(context, pageData.titleKey),
                  highlight: pageData.highlightWord,
                ),
              )
              .animate(onPlay: (controller) => controller.forward())
              .fadeIn(duration: 500.ms)
              .slideY(
                begin: 0.5,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 48),
          OrbitingIllustration(
            imageAsset: pageData.imageAsset,
            orbitAssets: pageData.orbitAssets,
            pageIndex: pageIndex,
          ),
          const SizedBox(height: 48),
          AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  AppLocalizations.getString(context, pageData.subtitleKey),
                  key: ValueKey(pageData.subtitleKey),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.forward())
              .fadeIn(duration: 500.ms)
              .slideY(
                begin: 0.5,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
