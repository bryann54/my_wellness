// lib/features/auth/data/models/onboarding_page_model.dart

class OnboardingPageModel {
  final String titleKey;
  final String subtitleKey;
  final String imageAsset;
  final List<String> orbitAssets;
  final String? highlightWord;

  const OnboardingPageModel({
    required this.titleKey,
    required this.subtitleKey,
    required this.imageAsset,
    required this.orbitAssets,
    this.highlightWord,
  });
}
