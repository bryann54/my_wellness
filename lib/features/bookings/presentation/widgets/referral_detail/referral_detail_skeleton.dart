import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class ReferralDetailSkeleton extends StatelessWidget {
  const ReferralDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        ShimmerBox(width: double.infinity, height: 130, radius: 16),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: double.infinity, height: 150, radius: 16),
        SizedBox(height: AppSpacing.md),
        ShimmerBox(width: 100, height: 14, radius: 4),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(width: double.infinity, height: 90, radius: 16),
      ],
    );
  }
}
