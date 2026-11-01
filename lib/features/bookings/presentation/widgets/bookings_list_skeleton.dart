import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class BookingsListSkeleton extends StatelessWidget {
  const BookingsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: const [
        _BookingCardSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _BookingCardSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _BookingCardSkeleton(),
        SizedBox(height: AppSpacing.sm),
        _BookingCardSkeleton(),
      ],
    );
  }
}

class _BookingCardSkeleton extends StatelessWidget {
  const _BookingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 4, height: 56, radius: 2),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 160, height: 15, radius: 4),
                SizedBox(height: 10),
                ShimmerBox(width: 120, height: 12, radius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 90, height: 12, radius: 4),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const ShimmerBox(width: 68, height: 22, radius: 11),
        ],
      ),
    );
  }
}
