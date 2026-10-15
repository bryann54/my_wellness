import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class AccountShimmer extends StatelessWidget {
  const AccountShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeholder = cs.surfaceContainerHighest.withValues(alpha: 0.6);

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 150,
          floating: false,
          pinned: true,
          backgroundColor: cs.surface,
          leading: const SizedBox.shrink(),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: cs.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  70,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    _block(
                      width: 80,
                      height: 80,
                      color: placeholder,
                      radius: 40,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _block(width: 150, height: 24, color: placeholder),
                          const SizedBox(height: AppSpacing.sm),
                          _block(width: 200, height: 16, color: placeholder),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _block(width: 100, height: 20, color: placeholder),
          ),
        ),
        ...List.generate(4, (index) => _menuItemShimmer(context, placeholder)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _block(width: 80, height: 20, color: placeholder),
          ),
        ),
        ...List.generate(5, (index) => _menuItemShimmer(context, placeholder)),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }

  Widget _block({
    required double width,
    required double height,
    required Color color,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _menuItemShimmer(BuildContext context, Color placeholder) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              _block(
                width: 40,
                height: 40,
                color: placeholder,
                radius: AppRadius.sm,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(width: 120, height: 16, color: placeholder),
                    const SizedBox(height: AppSpacing.sm),
                    _block(width: 80, height: 14, color: placeholder),
                  ],
                ),
              ),
              _block(width: 20, height: 20, color: placeholder, radius: 10),
            ],
          ),
        ),
      ),
    );
  }
}
