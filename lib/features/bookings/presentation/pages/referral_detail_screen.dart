import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/app_snackbar.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/bookings/domain/entities/facility.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/utils/booking_labels.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ReferralDetailScreen extends StatelessWidget {
  final String referralId;

  const ReferralDetailScreen({super.key, required this.referralId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingsBloc>(
      create: (_) {
        final bloc = getIt<BookingsBloc>();
        bloc.add(LoadReferralEvent(referralId));
        return bloc;
      },
      child: BookingsToastListener(child: _ReferralBody(id: referralId)),
    );
  }
}

class _ReferralBody extends StatelessWidget {
  final String id;

  const _ReferralBody({required this.id});

  Future<void> _navigate(BuildContext context, Facility f) async {
    final query = f.latitude != null && f.longitude != null
        ? '${f.latitude},${f.longitude}'
        : Uri.encodeComponent('${f.name} ${f.town}');
    final ok = await launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      AppSnackbar.error(
        context,
        AppLocalizations.getString(context, 'bookings.referral.mapsFailed'),
      );
    }
  }

  String _shaLabel(BuildContext context, String status) =>
      AppLocalizations.getString(context, switch (status) {
        'accredited' => 'bookings.referral.sha.accredited',
        'not_accredited' => 'bookings.referral.sha.notAccredited',
        _ => 'bookings.referral.sha.unavailable',
      });

  String _headline(BuildContext context, Referral r) =>
      r.escalationCategoryDisplay.isNotEmpty
      ? r.escalationCategoryDisplay
      : AppLocalizations.getString(context, 'bookings.referral.title');

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookingsBloc>().state;
    final r = state.referralDetail?.id == id ? state.referralDetail : null;
    final title = r != null ? _headline(context, r) : '';

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(title: title, isHome: false),
        ],
        body: _buildBody(context, state, r),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookingsState state, Referral? r) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (r == null) {
      if (state.referralDetailError != null && !state.referralDetailLoading) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.referralDetailError!,
                  textAlign: TextAlign.center,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  onPressed: () =>
                      context.read<BookingsBloc>().add(LoadReferralEvent(id)),
                  label: AppLocalizations.getString(context, 'common.retry'),
                  height: 48,
                ),
              ],
            ),
          ),
        );
      }
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 20, 40),
        children: const [
          ShimmerBox(width: 220, height: 22, radius: 6),
          SizedBox(height: AppSpacing.md),
          ShimmerParagraph(lines: 3),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: double.infinity, height: 150, radius: 16),
        ],
      );
    }

    final f = r.recommendedFacility;
    final b = r.booking;
    final completed =
        r.status == ReferralStatus.completed ||
        b?.statusEnum == BookingStatus.completed;
    final canBook =
        b == null && f != null && r.status != ReferralStatus.dismissed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, AppSpacing.md, 20, 40),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _headline(context, r),
                style: tt.titleLarge?.copyWith(color: cs.onSurface),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusChip.referral(context, r.status),
          ],
        ),
        if (r.reason.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            r.reason,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
        if (r.requiredServices.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final s in r.requiredServices) _Tag(label: s.name)],
          ),
        ],
        const SizedBox(height: AppSpacing.lg - 4),
        if (f == null)
          Text(
            AppLocalizations.getString(context, 'bookings.referral.noFacility'),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.name,
                  style: tt.titleSmall?.copyWith(color: cs.onSurface),
                ),
                if ([f.address, f.town].any((e) => e.isNotEmpty)) ...[
                  const SizedBox(height: 4),
                  Text(
                    [f.address, f.town].where((e) => e.isNotEmpty).join(', '),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (f.kephLevel != null) _Tag(label: 'KEPH ${f.kephLevel}'),
                    if (f.coversSha) const _Tag(label: 'SHA'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  [
                    if (r.distanceKm != null)
                      AppLocalizations.t(
                        context,
                        'bookings.referral.distanceKm',
                        {'km': r.distanceKm!},
                      ),
                    if (r.travelTimeMinutes != null)
                      AppLocalizations.t(context, 'bookings.referral.minutes', {
                        'min': '${r.travelTimeMinutes}',
                      }),
                    _shaLabel(context, r.shaAccreditationStatus),
                  ].join(' · '),
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg - 4),
        if (canBook)
          AppPrimaryButton(
            onPressed: () => context.router.push(
              CreateBookingRoute(
                serviceType: ServiceType.referralVisit,
                referralId: r.id,
                lockedFacility: f,
                serviceLabel: r.escalationCategoryDisplay,
              ),
            ),
            label: AppLocalizations.getString(
              context,
              'bookings.referral.book',
            ),
          ),
        if (b != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  b.serviceLabel,
                  style: tt.titleSmall?.copyWith(color: cs.onSurface),
                ),
              ),
              StatusChip.booking(context, b.statusEnum),
            ],
          ),
          const SizedBox(height: AppSpacing.md - 4),
          if (f != null)
            OutlinedButton.icon(
              onPressed: () => _navigate(context, f),
              icon: const Icon(Icons.directions_outlined),
              label: Text(
                AppLocalizations.getString(
                  context,
                  'bookings.referral.navigate',
                ),
              ),
            ),
          if (b.canBeManuallyCompleted) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: state.completing
                  ? null
                  : () => context.read<BookingsBloc>().add(
                      CompleteBookingEvent(b.id),
                    ),
              child: state.completing
                  ? const ShimmerBox(width: 42, height: 10, radius: 5)
                  : Text(
                      AppLocalizations.getString(
                        context,
                        'bookings.detail.markCompleted',
                      ),
                    ),
            ),
          ],
          if (b.checkedInAt != null &&
              b.statusEnum != BookingStatus.completed) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.login_rounded, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppLocalizations.t(
                      context,
                      'bookings.referral.checkedInAt',
                      {'time': formatStamp(b.checkedInAt!)},
                    ),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
          if (completed && f != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppPrimaryButton(
              onPressed: () => context.router.push(
                CreateBookingRoute(
                  serviceType: ServiceType.referralVisit,
                  serviceLabel: 'Follow-up — ${r.escalationCategoryDisplay}',
                  referralId: r.id,
                  lockedFacility: f,
                ),
              ),
              label: AppLocalizations.getString(
                context,
                'bookings.referral.bookFollowUp',
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
