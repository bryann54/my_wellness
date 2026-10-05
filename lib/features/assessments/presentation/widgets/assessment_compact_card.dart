import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';

class AssessmentCompactCard extends StatelessWidget {
  static const double height = 138;
  static const double widthFactor = 0.68;

  final AssessmentSummary summary;
  final VoidCallback onTap;

  const AssessmentCompactCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = screenWidth * widthFactor;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: cs.onPrimaryContainer.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: assessmentTitleTag(summary.slug),
                        flightShuttleBuilder: textShuttleBuilder,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            summary.shortTitle,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Hero(
                    tag: assessmentTaglineTag(summary.slug),
                    flightShuttleBuilder: textShuttleBuilder,
                    child: Material(
                      color: Colors.transparent,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          summary.tagline,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.4,
                            color: cs.onSurface.withValues(alpha: 0.62),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
