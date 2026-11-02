import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class BookingsListSkeleton extends StatelessWidget {
  const BookingsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: const [
        ShimmerBox(width: 130, height: 14, radius: 4),
        SizedBox(height: AppSpacing.sm + 2),
        ShimmerBox(width: double.infinity, height: 88, radius: 16),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(width: double.infinity, height: 88, radius: 16),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(width: double.infinity, height: 88, radius: 16),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(width: double.infinity, height: 88, radius: 16),
      ],
    );
  }
}
