import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/utils/booking_labels.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_hero.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

class BookingCard extends StatefulWidget {
  final ServiceBooking booking;

  const BookingCard({super.key, required this.booking});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _expanded = false;

  Future<void> _confirmComplete() async {
    final bookingId = widget.booking.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => CustomAlertDialog(
        title: AppLocalizations.getString(ctx, 'bookings.detail.confirmTitle'),

        content: Text(
          AppLocalizations.getString(ctx, 'bookings.detail.confirmBody'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.getString(ctx, 'common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.getString(ctx, 'common.confirm')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      HapticFeedback.mediumImpact();
      context.read<BookingsBloc>().add(CompleteBookingEvent(bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final b = widget.booking;

    final title = bookingServiceLabel(
      context,
      b.serviceType,
      b.serviceLabel,
      clinicianTier: b.clinicianTier,
    );
    final facility = b.facility?.name ?? b.preferredFacility;
    final meta = [
      if (facility.isNotEmpty) facility,
      if (b.preferredDate != null) b.preferredDate!,
      if (b.priceKes > 0) formatKes(context, b.priceKes),
    ].join(' · ');
    final canComplete = b.canBeManuallyCompleted;

    return Semantics(
      button: true,
      expanded: _expanded,
      label: meta.isEmpty ? title : '$title. $meta',
      excludeSemantics: true,
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _expanded = !_expanded);
          },
          child: AnimatedContainer(
            duration: AppDurations.medium,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookingHero(
                              tag: HeroTags.bookingTitle(b.id),
                              child: Text(
                                title,
                                maxLines: _expanded ? 4 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleSmall?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            if (meta.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                meta,
                                maxLines: _expanded ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      BookingHero(
                        tag: HeroTags.bookingStatus(b.id),
                        child: StatusChip.booking(context, b.status),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0.0,
                        duration: AppDurations.medium,
                        curve: Curves.easeOut,
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 20,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: AppDurations.medium,
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _expanded
                        ? _ExpandedDetails(
                            booking: b,
                            canComplete: canComplete,
                            onComplete: _confirmComplete,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final ServiceBooking booking;
  final bool canComplete;
  final Future<void> Function() onComplete;

  const _ExpandedDetails({
    required this.booking,
    required this.canComplete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final rows = <(String, String)>[
      if (booking.preferredDate != null)
        (
          AppLocalizations.getString(context, 'bookings.detail.preferredDate'),
          booking.preferredDate!,
        ),
      if (booking.checkedInAt != null)
        (
          AppLocalizations.getString(context, 'bookings.detail.checkedIn'),
          formatStamp(booking.checkedInAt!),
        ),
      if ((booking.facility?.name ?? booking.preferredFacility).isNotEmpty)
        (
          AppLocalizations.getString(context, 'bookings.detail.facility'),
          booking.facility?.name ?? booking.preferredFacility,
        ),
      if (booking.priceKes > 0)
        (
          AppLocalizations.getString(context, 'bookings.detail.price'),
          formatKes(context, booking.priceKes),
        ),
      if (booking.notes.isNotEmpty)
        (
          AppLocalizations.getString(context, 'bookings.detail.notes'),
          booking.notes,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: AppSpacing.lg,
          thickness: 1,
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
        if (booking.isHieManaged)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.getString(
                    context,
                    'bookings.detail.managedNote',
                  ),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          )
        else
          for (final (label, value) in rows) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ],
        if (canComplete) ...[
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<BookingsBloc, BookingsState>(
            buildWhen: (p, c) => p.completing != c.completing,
            builder: (context, state) => AppPrimaryButton(
              onPressed: state.completing ? null : onComplete,
              label: AppLocalizations.getString(
                context,
                'bookings.detail.markCompleted',
              ),
              isLoading: state.completing,
              height: 44,
            ),
          ),
        ],
      ],
    );
  }
}
