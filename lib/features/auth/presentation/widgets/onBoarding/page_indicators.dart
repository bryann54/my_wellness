import 'package:flutter/material.dart';
import 'package:my_wellness/features/auth/presentation/widgets/onBoarding/onBoarding_data.dart';

class PageIndicators extends StatelessWidget {
  final int current;
  const PageIndicators({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        OnboardingData.pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: index == current ? 24 : 8,
          decoration: BoxDecoration(
            color: index == current ? Colors.black : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
