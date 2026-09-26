import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

class CompleteSymptomAlerts extends StatelessWidget {
  final List<SymptomAlert> alerts;
  const CompleteSymptomAlerts({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.getString(context, 'assessment.warnings'),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final a in alerts) ...[
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
              const SizedBox(height: 4),
              Text(
                a.detail!,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.45,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
