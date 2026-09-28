import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final illustrationSize = (screenWidth * 0.68).clamp(220.0, 300.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          Flexible(
            child: Center(
              child: SizedBox(
                width: illustrationSize,
                height: illustrationSize,
                child: OrbitingIllustration(
                  imageAsset: pageData.imageAsset,
                  orbitAssets: pageData.orbitAssets,
                  pageIndex: pageIndex,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          OnboardingTitle(
            key: ValueKey(pageData.titleKey),
            title: AppLocalizations.getString(context, pageData.titleKey),
            highlight: pageData.highlightWord,
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              AppLocalizations.getString(context, pageData.subtitleKey),
              key: ValueKey(pageData.subtitleKey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.55,
                color: cs.onSurface.withValues(alpha: 0.79),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
