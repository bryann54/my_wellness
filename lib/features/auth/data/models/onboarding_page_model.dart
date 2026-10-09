import 'package:flutter/widgets.dart';

class OnboardingPageModel {
  const OnboardingPageModel({
    required this.titleKey,
    required this.subtitleKey,
    required this.imageAsset,
    required this.orbitIcons,
    this.highlightWord,
  });

  final String titleKey;
  final String subtitleKey;
  final String imageAsset;
  final List<IconData> orbitIcons;

  final String? highlightWord;
}
