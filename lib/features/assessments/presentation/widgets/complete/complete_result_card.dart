import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

class CompleteResultCard extends StatelessWidget {
  final AssessmentScore score;
  const CompleteResultCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final color = switch (score.band.toLowerCase()) {
      'lower' || 'low' => const Color(0xFF10B981), // green
      'moderate' => const Color(0xFFF59E0B), // amber
      'higher' || 'high' => const Color(0xFFDC2626), // red
      _ => cs.primary,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(
              context,
              'assessment.yourResult',
            ).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  score.bandLabel,
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (score.bandBlurb != null) ...[
            const SizedBox(height: 12),
            Text(
              score.bandBlurb!,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.55,
                color: cs.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
