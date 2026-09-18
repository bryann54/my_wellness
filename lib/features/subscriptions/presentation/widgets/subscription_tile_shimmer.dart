import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubscriptionPackageShimmer extends StatelessWidget {
  const SubscriptionPackageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child:
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    // Left Side: Title, Badge, Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(width: 120, height: 16), // Title
                          const SizedBox(height: 6),
                          _shimmerBox(width: 60, height: 12), // Type Badge
                          const SizedBox(height: 12),
                          _shimmerBox(
                            width: double.infinity,
                            height: 10,
                          ), // Desc Line 1
                          const SizedBox(height: 4),
                          _shimmerBox(width: 180, height: 10), // Desc Line 2
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right Side: Price + Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _shimmerBox(width: 70, height: 20), // Price
                        const SizedBox(height: 12),
                        _shimmerBox(
                          width: 110,
                          height: 36,
                          radius: 8,
                        ), // Button
                      ],
                    ),
                  ],
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1200.ms,
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Builder(
      builder: (context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
