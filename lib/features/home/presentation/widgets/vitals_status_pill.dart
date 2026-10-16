import 'package:flutter/material.dart';

enum VitalsTone { normal, low, attention, alert, neutral }

class VitalsStatusPill extends StatelessWidget {
  const VitalsStatusPill({
    super.key,
    required this.classification,
    this.label,
    this.compact = false,
  });

  /// Raw classification from the API (a clinical status like `elevated`, or a
  /// colour band like `blue`). Drives the pill colour.
  final String? classification;

  /// Optional human-readable text. When null it is derived from
  /// [classification]; bare colour bands never leak to the UI as "Blue".
  final String? label;
  final bool compact;

  static const _bands = {'green', 'blue', 'yellow', 'amber', 'orange', 'red'};

  static String _key(String? raw) =>
      (raw ?? '').toLowerCase().trim().replaceAll(RegExp(r'[\s\-]+'), '_');

  static VitalsTone toneFor(String? raw) {
    switch (_key(raw)) {
      case 'normal':
      case 'healthy':
      case 'optimal':
      case 'green':
        return VitalsTone.normal;
      case 'low':
      case 'low_blood_pressure':
      case 'hypotension':
      case 'hypoglycemia':
      case 'blue':
        return VitalsTone.low;
      case 'elevated':
      case 'prehypertension':
      case 'pre_hypertension':
      case 'pre_diabetes':
      case 'prediabetes':
      case 'borderline':
      case 'flagged_for_clinical_interpretation':
      case 'yellow':
      case 'amber':
      case 'orange':
        return VitalsTone.attention;
      case 'high':
      case 'stage_1':
      case 'stage_2':
      case 'hypertension':
      case 'diabetes':
      case 'critical':
      case 'red':
        return VitalsTone.alert;
      default:
        return VitalsTone.neutral;
    }
  }

  static String labelFor(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    // A bare colour band is meaningless to a patient; show the meaning.
    if (_bands.contains(_key(raw))) {
      return switch (toneFor(raw)) {
        VitalsTone.normal => 'Normal',
        VitalsTone.low => 'Low',
        VitalsTone.attention => 'Needs review',
        VitalsTone.alert => 'Alert',
        VitalsTone.neutral => '',
      };
    }
    return raw
        .trim()
        .replaceAll('_', ' ')
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// (foreground, background) for a tone.
  static (Color, Color) colorsFor(VitalsTone tone, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    switch (tone) {
      case VitalsTone.normal:
        return isDark
            ? (const Color(0xFF6EE7B7), const Color(0xFF064E3B))
            : (const Color(0xFF047857), const Color(0xFFECFDF5));
      case VitalsTone.low:
        return isDark
            ? (const Color(0xFF93C5FD), const Color(0xFF1E3A8A))
            : (const Color(0xFF1D4ED8), const Color(0xFFEFF6FF));
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
    final explicit = label?.trim() ?? '';
    final text = explicit.isNotEmpty ? explicit : labelFor(classification);
    if (text.isEmpty) return const SizedBox.shrink();

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
        // Keeps the pill legible on top of the tinted vitals tiles.
        border: Border.all(color: fg.withValues(alpha: 0.22), width: 0.75),
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
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                height: 1.1,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
