import 'package:flutter/material.dart';

import 'package:my_wellness/features/auth/data/models/onboarding_page_model.dart';

class OnboardingData {
  static List<OnboardingPageModel> get pages => const [
    OnboardingPageModel(
      titleKey: 'onboarding.pages.guidance.title',
      subtitleKey: 'onboarding.pages.guidance.subtitle',
      imageAsset: 'assets/images/onboarding_guidance.png',
      highlightWord: 'rights',
      orbitIcons: [
        Icons.menu_book_rounded,
        Icons.forum_rounded,
        Icons.verified_user_rounded,
      ],
    ),
    OnboardingPageModel(
      titleKey: 'onboarding.pages.secure.title',
      subtitleKey: 'onboarding.pages.secure.subtitle',
      imageAsset: 'assets/images/onboarding_secure.png',
      highlightWord: 'secure',
      orbitIcons: [
        Icons.shield_rounded,
        Icons.lock_rounded,
        Icons.fingerprint_rounded,
      ],
    ),
    OnboardingPageModel(
      titleKey: 'onboarding.pages.available.title',
      subtitleKey: 'onboarding.pages.available.subtitle',
      imageAsset: 'assets/images/onboarding_connect.png',
      highlightWord: 'available',
      orbitIcons: [
        Icons.schedule_rounded,
        Icons.support_agent_rounded,
        Icons.phone_in_talk_rounded,
      ],
    ),
    OnboardingPageModel(
      titleKey: 'onboarding.pages.resources.title',
      subtitleKey: 'onboarding.pages.resources.subtitle',
      imageAsset: 'assets/images/onboarding_resources.png',
      highlightWord: 'resources',
      orbitIcons: [
        Icons.medical_services_rounded,
        Icons.local_hospital_rounded,
        Icons.health_and_safety_rounded,
      ],
    ),
  ];
}
