import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;
  final Widget? leading;
  final Widget? trailing;

  const SectionLabel(
    this.label, {
    super.key,
    this.color,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = color ?? cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
