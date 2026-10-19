import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/features/home/presentation/widgets/vitals_status_pill.dart';

enum ReadingKind { bp, bs }

extension ReadingKindStyle on ReadingKind {
  IconData get icon => switch (this) {
    ReadingKind.bp => Icons.monitor_heart_rounded,
    ReadingKind.bs => Icons.water_drop_rounded,
  };

  (Color, Color) colorsFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (this) {
      ReadingKind.bp =>
        isDark
            ? (AppColors.vitalBpDark, AppColors.vitalBpSurfaceDark)
            : (AppColors.vitalBp, AppColors.vitalBpSurface),
      ReadingKind.bs =>
        isDark
            ? (AppColors.vitalBsDark, AppColors.vitalBsSurfaceDark)
            : (AppColors.vitalBs, AppColors.vitalBsSurface),
    };
  }
}

class LatestReadingCard extends StatelessWidget {
  final ReadingKind kind;
  final String classification;
  final String primary;
  final String unit;
  final String timestampIso;
  final String? secondary;
  final IconData? secondaryIcon;
  final String? primaryHeroTag;
  final String? timestampHeroTag;
  final String? classificationLabel;

  const LatestReadingCard({
    super.key,
    required this.kind,
    required this.classification,
    required this.primary,
    required this.unit,
    required this.timestampIso,
    this.secondary,
    this.secondaryIcon,
    this.primaryHeroTag,
    this.timestampHeroTag,
    this.classificationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final (accent, tint) = kind.colorsFor(theme.brightness);
    final onAccent = accent.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kind.icon, size: 18, color: onAccent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.getString(context, 'vitals.latestReading'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              VitalsStatusPill(classification: classification),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadingValue(
            primary: primary,
            unit: unit,
            heroTag: primaryHeroTag,
            color: cs.onSurface,
            mutedColor: cs.onSurface.withValues(alpha: 0.55),
          ),
          if (secondary != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (secondaryIcon != null) ...[
                  Icon(secondaryIcon, size: 15, color: accent),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    secondary!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          _ReadingTimestamp(
            value: friendlyDateTime(timestampIso),
            heroTag: timestampHeroTag,
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _ReadingValue extends StatelessWidget {
  const _ReadingValue({
    required this.primary,
    required this.unit,
    required this.color,
    required this.mutedColor,
    this.heroTag,
  });

  final String primary;
  final String unit;
  final Color color;
  final Color mutedColor;
  final String? heroTag;

  InlineSpan _span(TextStyle base) {
    final parts = primary.split('/');
    if (parts.length != 2) return TextSpan(text: primary);
    return TextSpan(
      children: [
        TextSpan(text: parts[0]),
        TextSpan(
          text: '/',
          style: base.copyWith(fontWeight: FontWeight.w300, color: mutedColor),
        ),
        TextSpan(text: parts[1]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      height: 1.0,
      color: color,
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(_span(base), style: base, maxLines: 1),
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: mutedColor,
            ),
          ),
        ),
      ],
    );
    final tag = heroTag;
    if (tag == null) return content;
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, _, _, _, toHero) =>
          (toHero.widget as Hero).child,
      child: Material(color: Colors.transparent, child: content),
    );
  }
}

class _ReadingTimestamp extends StatelessWidget {
  const _ReadingTimestamp({
    required this.value,
    required this.color,
    this.heroTag,
  });

  final String value;
  final Color color;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      value,
      style: GoogleFonts.inter(fontSize: 12, color: color),
    );
    final tag = heroTag;
    if (tag == null) return text;
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, _, _, _, toHero) =>
          (toHero.widget as Hero).child,
      child: Material(color: Colors.transparent, child: text),
    );
  }
}
