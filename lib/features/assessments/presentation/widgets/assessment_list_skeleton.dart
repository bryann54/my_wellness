import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class AssessmentListSkeleton extends StatelessWidget {
  const AssessmentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _SectionLabel(),
        SizedBox(height: 10),
        _HeroBox(),
        SizedBox(height: 28),
        _SectionLabel(),
        SizedBox(height: 10),
        _AssessmentRow(),
        SizedBox(height: 8),
        _AssessmentRow(),
        SizedBox(height: 24),
        _SectionLabel(),
        SizedBox(height: 10),
        _AssessmentRow(),
        SizedBox(height: 8),
        _AssessmentRow(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: ShimmerBox(width: 130, height: 14, radius: 4),
    );
  }
}

class _HeroBox extends StatelessWidget {
  const _HeroBox();

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(width: double.infinity, height: 166, radius: 20);
  }
}

class _AssessmentRow extends StatelessWidget {
  const _AssessmentRow();

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(width: double.infinity, height: 88, radius: 16);
  }
}
