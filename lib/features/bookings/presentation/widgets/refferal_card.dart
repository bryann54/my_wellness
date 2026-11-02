import 'package:flutter/material.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_hero.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

class ReferralCard extends StatelessWidget {
  static const double height = 152;
  static const double widthFactor = 0.68;

  final Referral referral;
  final VoidCallback onTap;

  const ReferralCard({super.key, required this.referral, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width * widthFactor;
    final title = referral.escalationCategoryDisplay.isNotEmpty
        ? referral.escalationCategoryDisplay
        : AppLocalizations.getString(context, 'bookings.referral.title');
    final subtitle = referral.recommendedFacility?.name ?? referral.reason;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: cs.onPrimaryContainer.withValues(alpha: 0.05),
        borderRadius: AppRadius.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
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
                      child: BookingHero(
                        tag: HeroTags.referralTitle(referral.id),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(color: cs.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: cs.onSurface.withValues(alpha: 0.28),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ),
                ),
                StatusChip.referral(context, referral.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
