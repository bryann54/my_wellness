import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/shimmer_box.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointments_toast_listener.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_card.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_section_label.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

const double _hPad = AppSpacing.md + AppSpacing.xs;

sealed class _MergedRow {
  DateTime? get sortDate;
}

class _AppointmentRow extends _MergedRow {
  _AppointmentRow(this.appointment);
  final Appointment appointment;

  @override
  DateTime? get sortDate =>
      parseDateTime(appointment.appointmentDate, appointment.appointmentTime);
}

class _BookingRow extends _MergedRow {
  _BookingRow(this.booking);
  final ServiceBooking booking;

  @override
  DateTime? get sortDate {
    final appointment = booking.appointmentTime;
    if (appointment != null) return appointment;
    final preferred = booking.preferredDate;
    if (preferred != null) {
      final parsed = DateTime.tryParse(preferred);
      if (parsed != null) return parsed;
    }
    return booking.createdAt;
  }
}

@RoutePage()
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  void _openAdd(BuildContext context) {
    context.router.push(const AddAppointmentRoute());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppointmentsBloc>(
          create: (_) {
            final bloc = getIt<AppointmentsBloc>();
            bloc.add(const LoadAppointmentsEvent());
            return bloc;
          },
        ),
        BlocProvider<BookingsBloc>(
          create: (_) {
            final bloc = BookingsBloc.factory();
            bloc.add(const LoadMyBookingsEvent());
            bloc.add(const LoadMyReferralsEvent());
            return bloc;
          },
        ),
      ],
      child: AppointmentsToastListener(
        child: BookingsToastListener(
          child: _Body(onAddPressed: () => _openAdd(context)),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final VoidCallback onAddPressed;

  const _Body({required this.onAddPressed});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 300) {
      return;
    }
    context.read<AppointmentsBloc>().add(const LoadMoreAppointmentsEvent());
    final bookings = context.read<BookingsBloc>();
    if (bookings.state.hasMore &&
        bookings.state.listStatus == BookingsListStatus.loaded) {
      bookings.add(const LoadMoreMyBookingsEvent());
    }
  }

  Future<void> _refresh() async {
    final appts = context.read<AppointmentsBloc>();
    final bookings = context.read<BookingsBloc>();

    appts.add(const LoadAppointmentsEvent());
    bookings.add(const LoadMyBookingsEvent(refresh: true));
    bookings.add(const LoadMyReferralsEvent(refresh: true));

    await Future.wait([
      appts.stream
          .firstWhere(
            (s) =>
                s.status == CollectionStatus.loaded ||
                s.status == CollectionStatus.error,
          )
          .timeout(const Duration(seconds: 15), onTimeout: () => appts.state),
      bookings.stream
          .firstWhere(
            (s) =>
                s.listStatus == BookingsListStatus.loaded ||
                s.listStatus == BookingsListStatus.error,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => bookings.state,
          ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppFabSlot(
        visible: true,
        child: AppFab.extended(
          label: AppLocalizations.getString(context, 'appointments.book'),
          icon: const Icon(Icons.add),
          onPressed: widget.onAddPressed,
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: NestedScrollView(
          controller: _scroll,
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title: AppLocalizations.getString(context, 'common.appointments'),
              isHome: false,
              isTabRoot: true,
            ),
          ],
          body: _MergedContent(onAddPressed: widget.onAddPressed),
        ),
      ),
    );
  }
}

class _MergedContent extends StatelessWidget {
  final VoidCallback onAddPressed;
  const _MergedContent({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      buildWhen: (p, c) =>
          p.status != c.status ||
          p.appointments != c.appointments ||
          p.cursor != c.cursor ||
          p.errorMessage != c.errorMessage,
      builder: (context, appts) {
        return BlocBuilder<BookingsBloc, BookingsState>(
          buildWhen: (p, c) =>
              p.listStatus != c.listStatus ||
              p.bookings != c.bookings ||
              p.nextCursor != c.nextCursor ||
              p.referrals != c.referrals ||
              p.listError != c.listError,
          builder: (context, bookings) => _MergedList(
            appointments: appts,
            bookings: bookings,
            onAddPressed: onAddPressed,
          ),
        );
      },
    );
  }
}

class _MergedList extends StatelessWidget {
  final AppointmentsState appointments;
  final BookingsState bookings;
  final VoidCallback onAddPressed;

  const _MergedList({
    required this.appointments,
    required this.bookings,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final loadingAppointments =
        appointments.status == CollectionStatus.loading &&
        appointments.appointments.isEmpty;
    final loadingBookings =
        bookings.listStatus == BookingsListStatus.loading &&
        bookings.bookings.isEmpty;

    if (loadingAppointments || loadingBookings) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(_hPad, 12, _hPad, 40),
        children: const [
          ShimmerBox(width: 130, height: 14, radius: 4),
          SizedBox(height: AppSpacing.sm + 2),
          ShimmerBox(width: double.infinity, height: 88, radius: 16),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: double.infinity, height: 88, radius: 16),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: double.infinity, height: 88, radius: 16),
        ],
      );
    }

    final error =
        appointments.status == CollectionStatus.error &&
            appointments.appointments.isEmpty &&
            bookings.listStatus == BookingsListStatus.error &&
            bookings.bookings.isEmpty
        ? (appointments.errorMessage ?? bookings.listError)
        : null;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final referrals = bookings.referrals
        .where((r) => r.status != ReferralStatus.dismissed)
        .take(10)
        .toList(growable: false);

    final rows =
        <_MergedRow>[
          ...appointments.appointments.map(_AppointmentRow.new),
          ...bookings.bookings.map(_BookingRow.new),
        ]..sort((a, b) {
          final ad = a.sortDate;
          final bd = b.sortDate;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });

    if (rows.isEmpty && referrals.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: AppSpacing.page,
                  child: VitalsEmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: AppLocalizations.getString(
                      context,
                      'appointments.empty',
                    ),
                    subtitle: AppLocalizations.getString(
                      context,
                      'appointments.emptySub',
                    ),
                    ctaLabel: AppLocalizations.getString(
                      context,
                      'appointments.book',
                    ),
                    onCta: onAddPressed,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final loadingMore =
        appointments.status == CollectionStatus.loading ||
        bookings.listStatus == BookingsListStatus.loadingMore;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (referrals.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md - 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: _hPad),
                  //   child: BookingSectionLabel(
                  //     AppLocalizations.getString(
                  //       context,
                  //       'bookings.referral.section',
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: AppSpacing.sm + 2),
                  // SizedBox(
                  //   height: ReferralCard.height,
                  //   child: ListView.separated(
                  //     scrollDirection: Axis.horizontal,
                  //     physics: const BouncingScrollPhysics(),
                  //     padding: const EdgeInsets.symmetric(horizontal: _hPad),
                  //     itemCount: referrals.length,
                  //     separatorBuilder: (_, _) =>
                  //         const SizedBox(width: AppSpacing.sm + 4),
                  //     itemBuilder: (context, i) => ReferralCard(
                  //       referral: referrals[i],
                  //       onTap: () => context.router.push(
                  //         ReferralDetailRoute(referralId: referrals[i].id),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        if (rows.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                _hPad,
                AppSpacing.md - 4,
                _hPad,
                AppSpacing.sm + 2,
              ),
              child: BookingSectionLabel(
                AppLocalizations.getString(
                  context,
                  'appointments.allAppointments',
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: _hPad),
            sliver: SliverList.separated(
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final row = rows[i];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: switch (row) {
                      _AppointmentRow(:final appointment) => AppointmentTile(
                        appointment: appointment,
                        onDelete: () => context.read<AppointmentsBloc>().add(
                          DeleteAppointmentEvent(appointment.id),
                        ),
                      ),
                      _BookingRow(:final booking) => BookingCard(
                        booking: booking,
                      ),
                    },
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 96),
              child: loadingMore
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}
