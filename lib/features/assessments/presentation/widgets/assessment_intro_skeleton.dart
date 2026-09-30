import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class AssessmentIntroSkeleton extends StatelessWidget {
  const AssessmentIntroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerLine(width: 220, height: 26),
          SizedBox(height: 10),
          ShimmerLine(width: 160, height: 26),

          SizedBox(height: 14),
          ShimmerParagraph(lines: 2),

          SizedBox(height: 28),
          ShimmerLine(width: 140, height: 15),

          SizedBox(height: 12),
          ShimmerParagraph(lines: 4),

          SizedBox(height: 28),
          ShimmerCard(height: 78),

          SizedBox(height: 36),
          ShimmerCard(height: 50, radius: 12),
        ],
      ),
    );
  }
}
