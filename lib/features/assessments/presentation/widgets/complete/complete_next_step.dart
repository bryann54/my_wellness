import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';

class CompleteNextStep extends StatelessWidget {
  final Referral? referral;
  final VoidCallback? onBook;

  const CompleteNextStep({super.key, this.referral, this.onBook});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = referral;

    if (r == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, size: 20, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.getString(
                  context,
                  'assessment.noActionNeeded',
                ),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.45,
                  color: cs.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final facility = r.recommendedFacility;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.getString(
            context,
            'assessment.nextStep',
          ).toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.escalationCategoryDisplay ?? r.escalationCategory,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: cs.onSurface,
                      ),
                    ),
                    if (r.reason != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        r.reason!,
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
              if (facility != null) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: cs.onSurface,
                        ),
                      ),
                      if (facility.locality.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          facility.locality,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      if (facility.coversSha || facility.kephLevel != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (facility.kephLevel != null)
                              _Tag('KEPH ${facility.kephLevel}'),
                            if (facility.coversSha) const _Tag('SHA'),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onBook,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            backgroundColor: cs.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.getString(
                              context,
                              'assessment.bookConsultation',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
