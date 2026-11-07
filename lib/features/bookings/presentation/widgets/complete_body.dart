import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/hex_color.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

class CompleteFindings extends StatelessWidget {
  final AssessmentScore score;
  final VoidCallback? onPrimaryCta;

  const CompleteFindings({super.key, required this.score, this.onPrimaryCta});

  Color _severityAccent(ColorScheme cs) {
    final fromApi = score.resultDisplay?.color?.accent;
    if (fromApi != null && fromApi.isNotEmpty) return hexToColor(fromApi);
    switch (score.severity) {
      case 'good':
        return const Color(0xFF158370);
      case 'attention':
        return const Color(0xFFB47C12);
      case 'concern':
        return const Color(0xFFC46E2B);
      case 'urgent':
        return const Color(0xFFB84140);
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = score.resultDisplay;
    if (display == null) return const SizedBox.shrink();

    final accent = _severityAccent(cs);
    final isEndo = display.kind == 'endometriosis';

    // The web uses specific background/border colors for the endometriosis card.
    // We fall back to the severity accent if those aren't provided.
    final cardBackground = display.color?.soft != null
        ? hexToColor(display.color!.soft)
        : accent.withValues(alpha: 0.06);
    final cardBorder = display.color?.accent != null
        ? hexToColor(display.color!.accent).withValues(alpha: 0.22)
        : accent.withValues(alpha: 0.22);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Main Result Card ---
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'YOUR RESULT',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (isEndo) ...[
                    const Spacer(),
                    Text(
                      'Understanding Your Symptoms',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (display.title != null && display.title!.isNotEmpty) ...[
                Text(
                  display.title!,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (display.body != null && display.body!.isNotEmpty)
                Text(
                  display.body!,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.5,
                    color: cs.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              if (!isEndo && display.metric != null) ...[
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${display.metric!.label}: ',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.5,
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      TextSpan(
                        text: display.metric!.value,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isEndo && display.primaryCtaLabel != null) ...[
                const SizedBox(height: 20),
                Text(
                  'NEXT STEP',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: onPrimaryCta,
                  icon: Icon(
                    display.severity == 'urgent'
                        ? Icons.local_hospital_outlined
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  iconAlignment: IconAlignment.start,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  label: Row(
                    children: [
                      Expanded(
                        child: Text(
                          display.primaryCtaLabel!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // --- Personalised Recommendation Card (Endometriosis) ---
        if (isEndo &&
            (display.recommendationHeading != null ||
                display.recommendationBody != null)) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PERSONALISED RECOMMENDATION',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (display.recommendationHeading != null) ...[
                  Text(
                    display.recommendationHeading!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (display.recommendationBody != null) ...[
                  Text(
                    display.recommendationBody!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (display.observations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHAT WE NOTICED',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final obs in display.observations)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    obs,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // --- Generic Sections (Nutrition / Symptoms) ---
        if (display.nutritionRecommendation != null) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Nutrition Recommendation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (display.nutritionRecommendation!.label != null)
                  Text(
                    display.nutritionRecommendation!.label!,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
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
                      fontSize: 12.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (display.symptomAlertsSection != null &&
            display.symptomAlertsSection!.alerts.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            title:
                display.symptomAlertsSection!.heading ??
                AppLocalizations.getString(context, 'assessment.warnings'),
            accent: accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (display.symptomAlertsSection!.intro != null) ...[
                  Text(
                    display.symptomAlertsSection!.intro!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                for (final a in display.symptomAlertsSection!.alerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
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
                              fontSize: 12.5,
                              height: 1.45,
                              color: cs.onSurface.withValues(alpha: 0.7),
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
                      fontSize: 12.5,
                      height: 1.45,
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? accent;

  const _SectionCard({required this.title, required this.child, this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: accent ?? cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
