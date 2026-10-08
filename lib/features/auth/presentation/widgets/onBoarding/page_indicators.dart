import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/onBoarding_data.dart';

class PageIndicators extends StatelessWidget {
  const PageIndicators({super.key, required this.current, this.count});

  final int current;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = count ?? OnboardingData.pages.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final selected = i == current;
        return AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: selected ? 22 : 6,
          decoration: BoxDecoration(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}