import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/utils/booking_labels.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_hero.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

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

  void _openReferral() {
    final referralId = widget.booking.referralId;
    if (referralId == null) return;
    HapticFeedback.selectionClick();
    context.router.push(ReferralDetailRoute(referralId: referralId));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
    ].join(' · ');

    final canComplete = b.canBeManuallyCompleted;
    final canOpen = b.referralId != null;

    final date =
        b.appointmentTime ??
        (b.preferredDate != null ? DateTime.tryParse(b.preferredDate!) : null);

    return Semantics(
      button: true,
      expanded: _expanded,
      label: meta.isEmpty ? title : '$title. $meta',
      excludeSemantics: true,
      child: _Card(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _expanded = !_expanded);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateBadge(date: date, cs: cs),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: canOpen ? _openReferral : null,
                          child: BookingHero(
                            tag: HeroTags.bookingTitle(b.id),
                            child: Text(
                              title,
                              maxLines: _expanded ? 4 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            meta,
                            maxLines: _expanded ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        if (b.priceKes > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            formatKes(context, b.priceKes),
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: cs.onSurface.withValues(alpha: 0.55),
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
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? _ExpandedDetails(
                        booking: b,
                        canComplete: canComplete,
                        canOpen: canOpen,
                        onOpen: _openReferral,
                        onComplete: _confirmComplete,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime? date;
  final ColorScheme cs;

  const _DateBadge({required this.date, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 56,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: date == null
          ? Icon(Icons.event_outlined, size: 22, color: cs.primary)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _months[date!.month - 1].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: cs.primary,
                  ),
                ),
                Text(
                  '${date!.day}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ExpandedDetails extends StatelessWidget {
  final ServiceBooking booking;
  final bool canComplete;
  final bool canOpen;
  final VoidCallback onOpen;
  final Future<void> Function() onComplete;

  const _ExpandedDetails({
    required this.booking,
    required this.canComplete,
    required this.canOpen,
    required this.onOpen,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
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
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        if (canOpen) ...[
          const SizedBox(height: AppSpacing.md - 4),
          TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              AppLocalizations.getString(
                context,
                'bookings.detail.openReferral',
              ),
            ),
          ),
        ],
        if (canComplete) ...[
          const SizedBox(height: AppSpacing.sm),
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

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
