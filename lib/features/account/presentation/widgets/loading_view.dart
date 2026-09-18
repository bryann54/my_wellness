// lib/features/account/presentation/widgets/account_shimmer.dart

import 'package:flutter/material.dart';
import 'package:my_wellness/common/widgets/shimmer.dart';

class AccountShimmer extends StatelessWidget {
  const AccountShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // Header area (app bar + expanded header)
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
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Row(
                  children: [
                    // Avatar shimmer
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Name and email shimmer
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).withShimmer(isLoading: true),
                          const SizedBox(height: 8),
                          Container(
                            width: 200,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ).withShimmer(isLoading: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Account section label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
            ).withShimmer(isLoading: true),
          ),
        ),
        // Account menu items (4 items)
        ...List.generate(4, (index) => _buildMenuItemShimmer(context)),
        // Help section label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Container(
              width: 80,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        // Help menu items (5 items)
        ...List.generate(5, (index) => _buildMenuItemShimmer(context)),
        // Footer space
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildMenuItemShimmer(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 16),
              // Title and subtitle placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron placeholder
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
