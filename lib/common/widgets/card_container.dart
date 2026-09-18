import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const CardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.32)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
