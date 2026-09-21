import 'package:flutter/material.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/onBoarding_data.dart';

class PageIndicators extends StatelessWidget {
  final int current;
  const PageIndicators({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(OnboardingData.pages.length, (index) {
        final selected = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: selected ? 24 : 8,
          decoration: BoxDecoration(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
