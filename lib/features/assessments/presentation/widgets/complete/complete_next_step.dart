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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
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
    final urgent = r.escalationCategory.toLowerCase().contains('urgent');

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: urgent
              ? cs.error.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      urgent
                          ? Icons.warning_amber_rounded
                          : Icons.local_hospital_outlined,
                      size: 18,
                      color: urgent ? cs.error : cs.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.escalationCategoryDisplay ?? r.escalationCategory,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (r.reason != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    r.reason!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onBook,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      iconAlignment: IconAlignment.end,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: urgent ? cs.error : cs.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      label: Text(
                        urgent ? 'Find urgent care' : 'Book consultation',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
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
    );
  }
}
