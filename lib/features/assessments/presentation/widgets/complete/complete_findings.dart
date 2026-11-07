import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/hex_color.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

class CompletePalette {
  final Color accent;
  final Color soft;
  final Color border;
  final Color button;
  final Color buttonText;

  const CompletePalette({
    required this.accent,
    required this.soft,
    required this.border,
    required this.button,
    required this.buttonText,
  });

  factory CompletePalette.of(AssessmentScore score, ColorScheme cs) {
    final api = score.resultDisplay?.color;
    if (api != null) {
      return CompletePalette(
        accent: hexToColor(api.accent),
        soft: hexToColor(api.soft),
        border: hexToColor(api.border),
        button: hexToColor(api.button),
        buttonText: hexToColor(api.buttonText),
      );
    }
    final (accent, soft, border) = switch (score.severity) {
      'good' => (
        const Color(0xFF158370),
        const Color(0xFFEDF8F3),
        const Color(0xFFCCE9DC),
      ),
      'attention' => (
        const Color(0xFFB47C12),
        const Color(0xFFFFF8E9),
        const Color(0xFFF4DFAE),
      ),
      'concern' => (
        const Color(0xFFC46E2B),
        const Color(0xFFFFF5EB),
        const Color(0xFFF4DAC4),
      ),
      'urgent' => (
        const Color(0xFFB84140),
        const Color(0xFFFFF1EF),
        const Color(0xFFF3D6D2),
      ),
      _ => (cs.primary, cs.surface, cs.outlineVariant),
    };
    return CompletePalette(
      accent: accent,
      soft: soft,
      border: border,
      button: accent,
      buttonText: Colors.white,
    );
  }
}

class CompleteFindings extends StatelessWidget {
  final AssessmentScore score;
  final VoidCallback? onPrimaryCta;
  final VoidCallback? onSecondaryCta;

  const CompleteFindings({
    super.key,
    required this.score,
    this.onPrimaryCta,
    this.onSecondaryCta,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = score.resultDisplay;
    if (display == null) return const SizedBox.shrink();

    final palette = CompletePalette.of(score, cs);
    final isEndo = display.kind == 'endometriosis';
    final hasTitle = display.title != null && display.title!.isNotEmpty;
    final hasBody = display.body != null && display.body!.isNotEmpty;
    final primary = display.primaryCtaLabel;
    final secondary = display.secondaryCtaLabel;
    final hasPrimary = isEndo && primary != null && primary.isNotEmpty;
    final hasSecondary = isEndo && secondary != null && secondary.isNotEmpty;
    final hasRecommendation =
        isEndo &&
        ((display.recommendationHeading ?? '').isNotEmpty ||
            (display.recommendationBody ?? '').isNotEmpty ||
            display.observations.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.soft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Your result', color: cs.onSurfaceVariant),
              if (hasTitle) ...[
                const SizedBox(height: 12),
                Text(
                  display.title!,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: cs.onSurface,
                  ),
                ),
              ],
              if (isEndo && display.categoryLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  display.categoryLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.accent,
                  ),
                ),
              ],
              if (hasBody) ...[
                const SizedBox(height: 12),
                Text(
                  display.body!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.55,
                    color: cs.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
              if (!isEndo && display.metric != null) ...[
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${display.metric!.label}: ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: display.metric!.value,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (hasPrimary || hasSecondary) ...[
                const SizedBox(height: 24),
                _Label('Next step', color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                if (hasPrimary)
                  FilledButton.icon(
                    onPressed: onPrimaryCta,
                    icon: Icon(
                      display.severity == 'urgent'
                          ? Icons.local_hospital_outlined
                          : Icons.arrow_forward_rounded,
                      size: 20,
                    ),
                    label: Text(
                      primary,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: palette.button,
                      foregroundColor: palette.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (hasPrimary && hasSecondary) const SizedBox(height: 10),
                if (hasSecondary)
                  OutlinedButton.icon(
                    onPressed: onSecondaryCta,
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: Text(
                      secondary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: palette.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (hasRecommendation)
          _Section(
            title: AppLocalizations.getString(
              context,
              'assessment.personalisedRecommendation',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((display.recommendationHeading ?? '').isNotEmpty) ...[
                  Text(
                    display.recommendationHeading!,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if ((display.recommendationBody ?? '').isNotEmpty)
                  Text(
                    display.recommendationBody!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                if (display.observations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Label('What we noticed', color: cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  for (final obs in display.observations) _Bullet(text: obs),
                ],
              ],
            ),
          ),
        if (display.nutritionRecommendation != null)
          _Section(
            title: AppLocalizations.getString(
              context,
              'assessment.nutritionRecommendation',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (display.nutritionRecommendation!.label != null)
                  Text(
                    display.nutritionRecommendation!.label!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: cs.onSurface,
                    ),
                  ),
                if (display.nutritionRecommendation!.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    display.nutritionRecommendation!.description!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (display.symptomAlertsSection != null &&
            display.symptomAlertsSection!.alerts.isNotEmpty)
          _Section(
            title:
                display.symptomAlertsSection!.heading ??
                AppLocalizations.getString(context, 'assessment.warnings'),
            accent: palette.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (display.symptomAlertsSection!.intro != null) ...[
                  Text(
                    display.symptomAlertsSection!.intro!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                for (final a in display.symptomAlertsSection!.alerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: cs.onSurface,
                          ),
                        ),
                        if (a.detail != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            a.detail!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.45,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (display.symptomAlertsSection!.outro != null)
                  Text(
                    display.symptomAlertsSection!.outro!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.45,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? accent;

  const _Section({required this.title, required this.child, this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          _Label(title, color: accent ?? cs.onSurfaceVariant),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.45,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
