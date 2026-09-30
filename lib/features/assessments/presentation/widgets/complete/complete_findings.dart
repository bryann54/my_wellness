import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

class CompleteFindings extends StatelessWidget {
  final AssessmentScore score;
  const CompleteFindings({super.key, required this.score});

  Color get _bandColor {
    return switch (score.band.toLowerCase()) {
      'lower' || 'low' => const Color(0xFF10B981),
      'moderate' => const Color(0xFFF59E0B),
      'higher' || 'high' => const Color(0xFFDC2626),
      _ => const Color(0xFF6B7280),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 44,
                  margin: const EdgeInsets.only(top: 2, right: 14),
                  decoration: BoxDecoration(
                    color: _bandColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.bandLabel,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: cs.onSurface,
                        ),
                      ),
                      if (score.bandBlurb != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          score.bandBlurb!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            color: cs.onSurface.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (score.symptomAlerts.isNotEmpty) ...[
            _Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.priority_high_rounded,
                        size: 16,
                        color: cs.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.getString(
                          context,
                          'assessment.warnings',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: cs.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final a in score.symptomAlerts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        a.detail != null ? '${a.title} — ${a.detail}' : a.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.45,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (score.recommendations.isNotEmpty) ...[
            _Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.getString(
                      context,
                      'assessment.recommendations',
                    ).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final r in score.recommendations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                    color: cs.onSurface,
                                  ),
                                ),
                                if (r.detail != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    r.detail!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      height: 1.45,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.35),
    );
  }
}
