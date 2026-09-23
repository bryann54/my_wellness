import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer.dart'; 
class MedicationTileShimmer extends StatelessWidget {
  const MedicationTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _SkeletonBox(width: 40, height: 40, radius: 11),
              const SizedBox(width: 12),
              // Two-line text column.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SkeletonBox(
                      width: double.infinity,
                      height: 13,
                      radius: 4,
                      widthFactor: 0.55,
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBox(
                      width: double.infinity,
                      height: 10,
                      radius: 4,
                      widthFactor: 0.35,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SkeletonBox(width: 20, height: 20, radius: 6),
            ],
          ),
        ),
      ),
    );
  }
}
class MedicationsShimmerList extends StatelessWidget {
  final int count;
  const MedicationsShimmerList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: count,
      itemBuilder: (_, __) => const MedicationTileShimmer(),
    );
  }
}

/// A single skeleton block that inherits your app's shimmer.
/// Uses `double.infinity` for width but constrains it with [widthFactor]
/// so the block doesn't span the entire row.
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double widthFactor;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    this.widthFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = width == double.infinity
            ? constraints.maxWidth * widthFactor
            : width;

        return Container(
          width: effectiveWidth,
          height: height,
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    ).withShimmer();
  }
}
