import 'package:flutter/material.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/widgets/hero_helpers.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

class BookingDetailHero extends StatelessWidget {
  /// `BookingSummary` from `BookingTimeline.booking` — NOT `ServiceBooking`.
  final BookingSummary booking;

  const BookingDetailHero({super.key, required this.booking});

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
                  tag: HeroTags.bookingCard(booking.id),
                  flightShuttleBuilder: textShuttleBuilder,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      booking.serviceLabel,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // BookingSummary.status is a String → statusEnum getter exists.
              StatusChip.booking(context, booking.statusEnum),
            ],
          ),
          if (booking.preferredDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _MetaRow(icon: Icons.event_outlined, label: booking.preferredDate!),
          ],
          if (booking.checkedInAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _MetaRow(
              icon: Icons.login_outlined,
              label: _stamp(booking.checkedInAt!),
            ),
          ],
          if (booking.isHieManaged) ...[
            const SizedBox(height: AppSpacing.sm),
            const _InfoNote(
              icon: Icons.info_outline,
              label: 'Managed by your HIE navigator.',
            ),
          ],
        ],
      ),
    );
  }

  String _stamp(DateTime d) => d.toLocal().toString().substring(0, 16);
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
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoNote({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
