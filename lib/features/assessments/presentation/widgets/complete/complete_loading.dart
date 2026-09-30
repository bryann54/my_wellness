import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';

class CompleteLoading extends StatelessWidget {
  const CompleteLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _HeroSkeleton(cs: cs),
            const SizedBox(height: 24),

            _FindingsSkeleton(cs: cs),
            const SizedBox(height: 24),
            _NextStepSkeleton(cs: cs),
            const SizedBox(height: 32),
            const ShimmerBox(width: double.infinity, height: 50, radius: 12),
            const SizedBox(height: 6),
            Center(child: const ShimmerBox(width: 180, height: 14, radius: 4)),
            const SizedBox(height: 10),
            Center(child: const ShimmerBox(width: 140, height: 12, radius: 4)),
          ],
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  final ColorScheme cs;
  const _HeroSkeleton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 32, height: 32, radius: 16),
              const SizedBox(width: 12),
              const ShimmerBox(width: 90, height: 13, radius: 4),
            ],
          ),
          const SizedBox(height: 20),

          const ShimmerBox(width: 240, height: 22, radius: 6),
          const SizedBox(height: 10),
          const ShimmerBox(width: 180, height: 22, radius: 6),

          const SizedBox(height: 14),
          const ShimmerBox(width: double.infinity, height: 13, radius: 4),
          const SizedBox(height: 8),
          const ShimmerBox(width: 220, height: 13, radius: 4),

          const SizedBox(height: 20),
          ShimmerBox(width: 190, height: 38, radius: 10),
        ],
      ),
    );
  }
}

class _FindingsSkeleton extends StatelessWidget {
  final ColorScheme cs;
  const _FindingsSkeleton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 4, height: 44, radius: 2),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: 140, height: 18, radius: 5),
                      const SizedBox(height: 10),
                      const ShimmerBox(
                        width: double.infinity,
                        height: 13,
                        radius: 4,
                      ),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 200, height: 13, radius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),

          // Recommendations section
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 130, height: 11, radius: 4),
                const SizedBox(height: 14),
                // 3 recommendation rows: dot + two-line text
                for (int i = 0; i < 3; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ShimmerBox(width: 5, height: 5, radius: 3),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShimmerBox(width: 200, height: 13, radius: 4),
                            const SizedBox(height: 6),
                            const ShimmerBox(
                              width: double.infinity,
                              height: 12,
                              radius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i < 2) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepSkeleton extends StatelessWidget {
  final ColorScheme cs;
  const _NextStepSkeleton({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(width: 90, height: 11, radius: 4),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Escalation category + reason
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 160, height: 15, radius: 5),
                    const SizedBox(height: 10),
                    const ShimmerBox(
                      width: double.infinity,
                      height: 13,
                      radius: 4,
                    ),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 220, height: 13, radius: 4),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 180, height: 14, radius: 5),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 120, height: 12, radius: 4),
                    const SizedBox(height: 12),

                    // Tags
                    Row(
                      children: const [
                        ShimmerBox(width: 60, height: 20, radius: 5),
                        SizedBox(width: 6),
                        ShimmerBox(width: 44, height: 20, radius: 5),
                      ],
                    ),

                    // Book CTA
                    const SizedBox(height: 16),
                    const ShimmerBox(
                      width: double.infinity,
                      height: 44,
                      radius: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
