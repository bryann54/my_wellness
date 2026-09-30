import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({super.key, this.width, this.height = 16, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(radius),
      ),
    ).withShimmer();
  }
}

class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  const ShimmerLine({super.key, this.width, this.height = 14})
    : assert(height > 0);

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: width, height: height, radius: 4);
}

class ShimmerParagraph extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double gap;

  const ShimmerParagraph({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines; i++) ...[
          ShimmerBox(
            width: i == lines - 1 ? 180 : double.infinity,
            height: lineHeight,
            radius: 4,
          ),
          if (i < lines - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 96,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: width, height: height, radius: radius);
}

class ShimmerCircle extends StatelessWidget {
  final double size;
  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: size, height: size, radius: size / 2);
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerCircle(size: 40),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 120),
                SizedBox(height: 8),
                ShimmerLine(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerLatestCard extends StatelessWidget {
  const ShimmerLatestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          ShimmerBox(width: 56, height: 56, radius: 16),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 90, height: 12),
                SizedBox(height: 10),
                ShimmerLine(width: 140, height: 24),
                SizedBox(height: 8),
                ShimmerLine(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
