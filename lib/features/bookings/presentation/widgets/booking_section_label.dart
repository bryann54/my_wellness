import 'package:flutter/material.dart';

class BookingSectionLabel extends StatelessWidget {
  final String label;

  const BookingSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
