import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/auth/data/models/onboarding_page_model.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/on_boarding_title.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/orbiting_illustration.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    required this.pageData,
    required this.pageIndex,
    super.key,
  });

  final OnboardingPageModel pageData;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final illustrationSize = (screenWidth * 0.72).clamp(240.0, 320.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),

          Flexible(
            child: Center(
              child: SizedBox(
                width: illustrationSize,
                height: illustrationSize,
                child: OrbitingIllustration(
                  imageAsset: pageData.imageAsset,
                  orbitIcons: pageData.orbitIcons,
                  pageIndex: pageIndex,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          OnboardingTitle(
            key: ValueKey(pageData.titleKey),
            title: AppLocalizations.getString(context, pageData.titleKey),
            highlight: pageData.highlightWord,
          ),

          const SizedBox(height: AppSpacing.sm),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              AppLocalizations.getString(context, pageData.subtitleKey),
              key: ValueKey(pageData.subtitleKey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.79),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
