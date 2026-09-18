// lib/features/auth/presentation/widgets/onboarding_data.dart

import 'package:my_wellness/features/auth/data/models/onboarding_page_model.dart';

class OnboardingData {
  static List<OnboardingPageModel> get pages => [
        const OnboardingPageModel(
          titleKey: 'onboarding.pages.guidance.title',
          subtitleKey: 'onboarding.pages.guidance.subtitle',
          imageAsset: 'assets/images/onboarding_guidance.png',
          highlightWord: 'rights',
          orbitAssets: [
            'assets/images/orbit_chat.png',
            'assets/images/orbit_signal.png',
            'assets/images/orbit_book.png',
          ],
        ),
        const OnboardingPageModel(
          titleKey: 'onboarding.pages.secure.title',
          subtitleKey: 'onboarding.pages.secure.subtitle',
          imageAsset: 'assets/images/onboarding_secure.png',
          highlightWord: 'secure',
          orbitAssets: [
            'assets/images/orbit_book.png',
            'assets/images/orbit_chat.png',
            'assets/images/orbit_signal.png',
          ],
        ),
        const OnboardingPageModel(
          titleKey: 'onboarding.pages.available.title',
          subtitleKey: 'onboarding.pages.available.subtitle',
          imageAsset: 'assets/images/onboarding_connect.png',
          highlightWord: 'available',
          orbitAssets: [
            'assets/images/orbit_signal.png',
            'assets/images/orbit_book.png',
            'assets/images/orbit_chat.png',
          ],
        ),
        const OnboardingPageModel(
          titleKey: 'onboarding.pages.resources.title',
          subtitleKey: 'onboarding.pages.resources.subtitle',
          imageAsset: 'assets/images/onboarding_resources.png',
          highlightWord: 'resources',
          orbitAssets: [
            'assets/images/orbit_chat.png',
            'assets/images/orbit_signal.png',
            'assets/images/orbit_book.png',
          ],
        ),
      ];
}
