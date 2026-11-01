import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/colors.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.booking(BuildContext context, BookingStatus status) {
    final cs = Theme.of(context).colorScheme;
    final (key, color) = switch (status) {
      BookingStatus.pending => ('pending', AppColors.warning),
      BookingStatus.confirmed => ('confirmed', AppColors.info),
      BookingStatus.paid => ('paid', AppColors.success),
      BookingStatus.cancelled => ('cancelled', cs.error),
      BookingStatus.completed => ('completed', cs.primary),
      BookingStatus.unknown => ('unknown', cs.onSurfaceVariant),
    };
    return StatusChip(
      label: AppLocalizations.getString(context, 'bookings.status.$key'),
      color: color,
    );
  }

  factory StatusChip.referral(BuildContext context, ReferralStatus status) {
    final cs = Theme.of(context).colorScheme;
    final (key, color) = switch (status) {
      ReferralStatus.generated => ('generated', AppColors.info),
      ReferralStatus.viewed => ('viewed', AppColors.info),
      ReferralStatus.booked => ('booked', AppColors.warning),
      ReferralStatus.completed => ('completed', cs.primary),
      ReferralStatus.dismissed => ('dismissed', cs.onSurfaceVariant),
      ReferralStatus.unknown => ('unknown', cs.onSurfaceVariant),
    };
    return StatusChip(
      label: AppLocalizations.getString(
        context,
        'bookings.referral.status.$key',
      ),
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
