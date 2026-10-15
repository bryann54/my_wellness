import 'package:flutter/material.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class AccountSectionCard extends StatelessWidget {
  const AccountSectionCard({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class AccountSectionDivider extends StatelessWidget {
  const AccountSectionDivider({super.key});

  static const double indent = 68;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: indent,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }
}