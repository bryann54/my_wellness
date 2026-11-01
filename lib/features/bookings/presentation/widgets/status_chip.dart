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
    final (labelKey, color) = switch (status) {
      BookingStatus.pending => (
        'bookings.status.pending',
        AppColors.statusPending,
      ),
      BookingStatus.confirmed => (
        'bookings.status.confirmed',
        AppColors.statusConfirmed,
      ),
      BookingStatus.paid => ('bookings.status.paid', AppColors.statusPaid),
      BookingStatus.cancelled => (
        'bookings.status.cancelled',
        AppColors.statusCancelled,
      ),
      BookingStatus.completed => (
        'bookings.status.completed',
        AppColors.statusCompleted,
      ),
      BookingStatus.unknown => (
        'bookings.status.unknown',
        AppColors.statusUnknown,
      ),
    };
    return StatusChip(
      label: AppLocalizations.getString(context, labelKey),
      color: color,
    );
  }

  factory StatusChip.referral(BuildContext context, ReferralStatus status) {
    final (labelKey, color) = switch (status) {
      ReferralStatus.generated => (
        'referral.status.generated',
        AppColors.referralGenerated,
      ),
      ReferralStatus.viewed => (
        'referral.status.viewed',
        AppColors.referralViewed,
      ),
      ReferralStatus.booked => (
        'referral.status.booked',
        AppColors.referralBooked,
      ),
      ReferralStatus.completed => (
        'referral.status.completed',
        AppColors.referralCompleted,
      ),
      ReferralStatus.dismissed => (
        'referral.status.dismissed',
        AppColors.referralDismissed,
      ),
      ReferralStatus.unknown => (
        'referral.status.unknown',
        AppColors.statusUnknown,
      ),
    };
    return StatusChip(
      label: AppLocalizations.getString(context, labelKey),
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = _readableOn(color, theme.brightness);
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _readableOn(Color accent, Brightness brightness) {
    if (brightness == Brightness.dark) return accent;
    final hsl = HSLColor.fromColor(accent);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
  }
}
