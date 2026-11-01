import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/error_state.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/referral_detail/referral_detail_booking_card.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/referral_detail/referral_detail_facility_card.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/referral_detail/referral_detail_hero.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/referral_detail/referral_detail_skeleton.dart';

@RoutePage()
class ReferralDetailScreen extends StatelessWidget {
  final String referralId;

  const ReferralDetailScreen({super.key, required this.referralId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BookingsBloc>(),
      child: BookingToastListener(
        child: _ReferralDetailBody(referralId: referralId),
      ),
    );
  }
}

class _ReferralDetailBody extends StatefulWidget {
  final String referralId;

  const _ReferralDetailBody({required this.referralId});

  @override
  State<_ReferralDetailBody> createState() => _ReferralDetailBodyState();
}

class _ReferralDetailBodyState extends State<_ReferralDetailBody> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(LoadReferralEvent(widget.referralId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'referral.title'),
            isHome: false,
          ),
        ],
        body: BlocBuilder<BookingsBloc, BookingsState>(
          buildWhen: (p, c) =>
              p.referralDetail != c.referralDetail ||
              p.referralDetailLoading != c.referralDetailLoading ||
              p.referralDetailError != c.referralDetailError ||
              p.completing != c.completing,
          builder: (context, state) {
            if (state.referralDetailError != null &&
                state.referralDetail == null) {
              return RefreshIndicator(
                onRefresh: () async => context.read<BookingsBloc>().add(
                  LoadReferralEvent(widget.referralId),
                ),
                child: ErrorState(
                  message: state.referralDetailError!,
                  onRetry: () => context.read<BookingsBloc>().add(
                    LoadReferralEvent(widget.referralId),
                  ),
                ),
              );
            }
            final r = state.referralDetail;
            if (r == null || r.id != widget.referralId) {
              return const ReferralDetailSkeleton();
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<BookingsBloc>().add(
                LoadReferralEvent(widget.referralId, silent: true),
              ),
              child: _buildBody(context, state, r),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookingsState state, Referral r) {
    final b = r.booking;
    final completed =
        r.status == ReferralStatus.completed ||
        b?.status ==
            BookingStatus.completed; // VERIFY: b.status vs b.statusEnum

    final detailBookingId = b == null
        ? null
        : (b.followUpToId != null &&
                  b.checkedInAt == null &&
                  b.status !=
                      BookingStatus
                          .completed // VERIFY
              ? b.followUpToId!
              : b.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        ReferralDetailHero(referral: r),
        const SizedBox(height: AppSpacing.md),
        ReferralDetailFacilityCard(referral: r),
        const SizedBox(height: AppSpacing.md),
        if (b == null &&
            r.recommendedFacility != null &&
            r.status != ReferralStatus.dismissed)
          FilledButton(
            onPressed: () => context.router.push(
              CreateBookingRoute(
                serviceType: ServiceType.referralVisit,
                referral: r,
              ),
            ),
            child: Text(
              AppLocalizations.getString(context, 'referral.bookConsultation'),
            ),
          ),
        if (b != null) ...[
          ReferralDetailBookingCard(
            booking: b, // now correctly a BookingSummary
            completing: state.completing,
            showComplete: b.canBeManuallyCompleted,
            showViewDetails:
                b.checkedInAt != null || completed || b.followUpToId != null,
            onComplete: () =>
                context.read<BookingsBloc>().add(CompleteBookingEvent(b.id)),
            onViewDetails: () => context.router.push(
              BookingDetailRoute(bookingId: detailBookingId!),
            ),
          ),
          if (completed && r.recommendedFacility != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => context.router.push(
                CreateBookingRoute(
                  serviceType: ServiceType.referralVisit,
                  referral: r,
                  followUp: true,
                ),
              ),
              child: Text(
                AppLocalizations.getString(context, 'referral.bookFollowUp'),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
