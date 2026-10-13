import 'package:flutter/material.dart';

class OrbitIcon extends StatelessWidget {
  const OrbitIcon({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.16),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
      ),
    );
  }
}
