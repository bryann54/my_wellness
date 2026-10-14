import 'package:flutter/material.dart';

enum VitalsTone { normal, attention, alert, neutral }

class VitalsStatusPill extends StatelessWidget {
  const VitalsStatusPill({
    super.key,
    required this.classification,
    this.compact = false,
  });

  final String? classification;
  final bool compact;

  static VitalsTone toneFor(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'normal':
      case 'healthy':
      case 'optimal':
        return VitalsTone.normal;
      case 'elevated':
      case 'prehypertension':
      case 'pre_hypertension':
      case 'pre_diabetes':
      case 'prediabetes':
      case 'borderline':
        return VitalsTone.attention;
      case 'high':
      case 'stage_1':
      case 'stage_2':
      case 'hypertension':
      case 'diabetes':
      case 'critical':
        return VitalsTone.alert;
      case 'low':
      case 'hypotension':
      case 'hypoglycemia':
        return VitalsTone.attention;
      default:
        return VitalsTone.neutral;
    }
  }

  static String labelFor(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    return raw
        .trim()
        .replaceAll('_', ' ')
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// (foreground, background) for a tone. Public so tiles can reuse the
  /// tone colour (e.g. to tint the border when a reading needs attention).
  static (Color, Color) colorsFor(VitalsTone tone, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    switch (tone) {
      case VitalsTone.normal:
        return isDark
            ? (const Color(0xFF6EE7B7), const Color(0xFF064E3B))
            : (const Color(0xFF047857), const Color(0xFFECFDF5));
      case VitalsTone.attention:
        return isDark
            ? (const Color(0xFFFCD34D), const Color(0xFF78350F))
            : (const Color(0xFFB45309), const Color(0xFFFFFBEB));
      case VitalsTone.alert:
        return isDark
            ? (const Color(0xFFFCA5A5), const Color(0xFF7F1D1D))
            : (const Color(0xFFB91C1C), const Color(0xFFFEF2F2));
      case VitalsTone.neutral:
        return (
          theme.colorScheme.onSurfaceVariant,
          theme.colorScheme.surfaceContainerHighest,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = labelFor(classification);
    if (label.isEmpty) return const SizedBox.shrink();

    final tone = toneFor(classification);
    final (fg, bg) = colorsFor(tone, Theme.of(context));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              height: 1.1,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
