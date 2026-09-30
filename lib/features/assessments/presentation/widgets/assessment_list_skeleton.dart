import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class AssessmentListSkeleton extends StatelessWidget {
  const AssessmentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _SectionLabel(),
        SizedBox(height: 10),
        _HeroBox(),
        SizedBox(height: 24),
        _SectionLabel(),
        SizedBox(height: 10),
        _Rail(),
        SizedBox(height: 24),
        _SectionLabel(),
        SizedBox(height: 10),
        _Rail(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Row(
        children: [
          ShimmerBox(width: 18, height: 18, radius: 5),
          SizedBox(width: 8),
          ShimmerBox(width: 110, height: 12, radius: 4),
        ],
      ),
    );
  }
}

class _HeroBox extends StatelessWidget {
  const _HeroBox();

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(width: double.infinity, height: 78, radius: 14);
  }
}

class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.68;

    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) =>
            ShimmerBox(width: cardWidth, height: 138, radius: 14),
      ),
    );
  }
}
