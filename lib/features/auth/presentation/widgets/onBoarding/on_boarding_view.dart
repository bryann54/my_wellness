import 'package:flutter/material.dart';
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
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Hero(
              tag: hero_onboarding_logo,
              child: SizedBox(
                height: 72,
                width: 72,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: OnboardingTitle(
              key: ValueKey(pageData.titleKey),
              title: AppLocalizations.getString(context, pageData.titleKey),
              highlight: pageData.highlightWord,
            ),
          ),

          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: OrbitingIllustration(
                imageAsset: pageData.imageAsset,
                orbitAssets: pageData.orbitAssets,
                pageIndex: pageIndex,
              ),
            ),
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              AppLocalizations.getString(context, pageData.subtitleKey),
              key: ValueKey(pageData.subtitleKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
