import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class NotificationTileShimmer extends StatelessWidget {
  const NotificationTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 40, height: 40, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 180, height: 14, radius: 4),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 12, radius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 220, height: 12, radius: 4),
                SizedBox(height: 10),
                ShimmerBox(width: 80, height: 10, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsShimmerList extends StatelessWidget {
  final int count;
  const NotificationsShimmerList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: count,
      itemBuilder: (_, __) => const NotificationTileShimmer(),
    );
  }
}
