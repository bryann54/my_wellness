import 'package:flutter/material.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/hero_helpers.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

class ReferralDetailBookingCard extends StatelessWidget {
  /// `BookingSummary` from `domain/entities/service_booking.dart`.
  /// Do NOT pass `ServiceBooking` here — `Referral.booking` is a summary.
  final BookingSummary booking;
  final bool completing;
  final VoidCallback onComplete;
  final VoidCallback onViewDetails;
  final bool showComplete;
  final bool showViewDetails;

  const ReferralDetailBookingCard({
    super.key,
    required this.booking,
    required this.completing,
    required this.onComplete,
    required this.onViewDetails,
    required this.showComplete,
    required this.showViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: HeroTags.referralBookingCard(booking.id),
                  flightShuttleBuilder: textShuttleBuilder,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      booking.serviceLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              StatusChip.booking(context, booking.statusEnum),
            ],
          ),
          if (showComplete || showViewDetails) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (showComplete)
                  OutlinedButton(
                    onPressed: completing ? null : onComplete,
                    child: Text(
                      AppLocalizations.getString(
                        context,
                        'bookings.markCompleted',
                      ),
                    ),
                  ),
                if (showViewDetails)
                  OutlinedButton(
                    onPressed: onViewDetails,
                    child: Text(
                      AppLocalizations.getString(
                        context,
                        'referral.viewVisitDetails',
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
