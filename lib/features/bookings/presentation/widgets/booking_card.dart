import 'package:flutter/material.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/hero_helpers.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

class BookingCard extends StatelessWidget {
  final ServiceBooking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  Color _accent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (booking.status) {
      BookingStatus.pending => const Color(0xFFF59E0B),
      BookingStatus.confirmed => const Color(0xFF3B82F6),
      BookingStatus.paid => const Color(0xFF10B981),
      BookingStatus.cancelled => cs.error,
      BookingStatus.completed => const Color(0xFF14B8A6),
      BookingStatus.unknown => cs.onSurface.withValues(alpha: 0.4),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final accent = _accent(context);
    final facility = booking.facility?.name ?? booking.preferredFacility;

    final metaRows = <Widget>[
      if (facility.isNotEmpty)
        _MetaRow(icon: Icons.local_hospital_outlined, label: facility),
      if (booking.preferredDate != null)
        _MetaRow(icon: Icons.event_outlined, label: booking.preferredDate!),
      if (booking.priceKes > 0)
        _MetaRow(
          icon: Icons.payments_outlined,
          label: AppLocalizations.t(context, 'bookings.priceKes', {
            'amount': '${booking.priceKes}',
          }),
        ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: HeroTags.bookingCard(booking.id),
                              flightShuttleBuilder: textShuttleBuilder,
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  booking.serviceLabel,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),
                            if (metaRows.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Hero(
                                tag: HeroTags.bookingCardMeta(booking.id),
                                flightShuttleBuilder: textShuttleBuilder,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: metaRows,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip.booking(context, booking.status),
                          const SizedBox(height: AppSpacing.sm),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: cs.onSurface.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: cs.onSurface.withValues(alpha: 0.55)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
