import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';

class CompleteRecommendedCare extends StatelessWidget {
  final Referral referral;
  const CompleteRecommendedCare({super.key, required this.referral});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUrgent = referral.escalationCategory.toLowerCase() == 'urgent';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUrgent
                    ? Icons.priority_high_rounded
                    : Icons.check_circle_outline,
                size: 20,
                color: isUrgent ? const Color(0xFFDC2626) : cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.getString(
                  context,
                  'assessment.recommendedCare',
                ),
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            referral.escalationCategoryDisplay ?? referral.escalationCategory,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isUrgent ? const Color(0xFFDC2626) : cs.onSurface,
              height: 1.35,
            ),
          ),
          if (referral.reason != null) ...[
            const SizedBox(height: 6),
            Text(
              referral.reason!,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
          if (referral.requiredServices.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in referral.requiredServices)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      s.name,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
