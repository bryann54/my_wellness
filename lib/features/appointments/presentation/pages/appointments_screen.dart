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
import 'package:my_wellness/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointments_search_bar_bottom.dart';
import 'package:my_wellness/features/appointments/presentation/widgets/appointments_toast_listener.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_card.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_section_label.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/vitals/domain/entities/appointment.dart';
import 'package:my_wellness/features/vitals/presentation/widgets/vitals_empty_state.dart';

const double _hPad = AppSpacing.md + AppSpacing.xs;

bool shouldShowAppointmentsFab({
  required bool hasAppointments,
  required bool hasBookings,
}) => hasAppointments || hasBookings;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingsBloc>(
      create: (_) {
        final bloc = BookingsBloc.factory();
        bloc.add(const LoadMyBookingsEvent());
        return bloc;
      },
      child: AppointmentsToastListener(
        child: BookingsToastListener(child: const _Body()),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AppointmentsBloc>().add(const LoadAppointmentsEvent());
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
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

  void _onSearchChanged(String value) {
    context.read<AppointmentsBloc>().add(SearchAppointmentsEvent(value));
    context.read<BookingsBloc>().add(SearchBookingsEvent(value));
  }

  void _openAdd() {
    // Use this route's context so the shared AppointmentsBloc remains
    // available to AddAppointmentScreen.
    context.router.push(const AddAppointmentRoute());
  }

  Future<void> _refresh() async {
    final appts = context.read<AppointmentsBloc>();
    final bookings = context.read<BookingsBloc>();

    appts.add(const LoadAppointmentsEvent());
    bookings.add(const LoadMyBookingsEvent(refresh: true));

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
    final hasAppointments = context.select<AppointmentsBloc, bool>(
      (bloc) => bloc.state.appointments.isNotEmpty,
    );
    final hasBookings = context.select<BookingsBloc, bool>(
      (bloc) => bloc.state.bookings.isNotEmpty,
    );

    // Lists are cursor-paginated and filtered client-side, so while a query
    // is active keep pulling pages until the cursor is exhausted. Firing only
    // when the cursor changes prevents a retry loop after a failed page.
    return MultiBlocListener(
      listeners: [
        BlocListener<AppointmentsBloc, AppointmentsState>(
          listenWhen: (p, c) =>
              c.isSearching &&
              c.cursor != null &&
              !c.loadingMore &&
              c.status == CollectionStatus.loaded &&
              (p.searchQuery != c.searchQuery || p.cursor != c.cursor),
          listener: (context, _) => context.read<AppointmentsBloc>().add(
            const LoadMoreAppointmentsEvent(),
          ),
        ),
        BlocListener<BookingsBloc, BookingsState>(
          listenWhen: (p, c) =>
              c.searchQuery.trim().isNotEmpty &&
              c.hasMore &&
              c.listStatus == BookingsListStatus.loaded &&
              (p.searchQuery != c.searchQuery || p.nextCursor != c.nextCursor),
          listener: (context, _) =>
              context.read<BookingsBloc>().add(const LoadMoreMyBookingsEvent()),
        ),
      ],
      child: Scaffold(
        floatingActionButton: AppFabSlot(
          // The true empty state already owns the primary booking CTA.
          // Show the persistent action once there is content to accompany it.
          visible: shouldShowAppointmentsFab(
            hasAppointments: hasAppointments,
            hasBookings: hasBookings,
          ),
          child: AppFab.extended(
            label: AppLocalizations.getString(context, 'appointments.book'),
            icon: const Icon(Icons.add),
            onPressed: _openAdd,
          ),
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: NestedScrollView(
            controller: _scroll,
            headerSliverBuilder: (_, _) => [
              CustomAppBar(
                title: AppLocalizations.getString(
                  context,
                  'common.appointments',
                ),
                isHome: false,
                isTabRoot: true,
                bottom: AppointmentsSearchBarBottom(
                  controller: _search,
                  hintText: AppLocalizations.getString(
                    context,
                    'appointments.searchHint',
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ],
            body: _MergedContent(onAddPressed: _openAdd),
          ),
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
          p.loadingMore != c.loadingMore ||
          p.searchQuery != c.searchQuery ||
          p.errorMessage != c.errorMessage,
      builder: (context, appts) {
        return BlocBuilder<BookingsBloc, BookingsState>(
          buildWhen: (p, c) =>
              p.listStatus != c.listStatus ||
              p.bookings != c.bookings ||
              p.nextCursor != c.nextCursor ||
              p.searchQuery != c.searchQuery ||
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

    final rows =
        <_MergedRow>[
          ...appointments.filteredAppointments.map(_AppointmentRow.new),
          ...bookings.filteredBookings.map(_BookingRow.new),
        ]..sort((a, b) {
          final ad = a.sortDate;
          final bd = b.sortDate;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });

    if (rows.isEmpty) {
      if (appointments.isSearching) {
        final stillSearching = appointments.cursor != null || bookings.hasMore;
        return _NoResults(
          query: appointments.searchQuery,
          loading: stillSearching,
        );
      }
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
        appointments.loadingMore ||
        bookings.listStatus == BookingsListStatus.loadingMore;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              _hPad,
              AppSpacing.md,
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
                ? const Center(
                    child: ShimmerBox(width: 96, height: 12, radius: 6),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final bool loading;

  const _NoResults({required this.query, required this.loading});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(
        vertical: 80,
        horizontal: AppSpacing.xl,
      ),
      children: [
        if (loading)
          const Center(child: ShimmerBox(width: 96, height: 12, radius: 6))
        else ...[
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: cs.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLocalizations.t(context, 'appointments.noResults', {
              'query': query.trim(),
            }),
            textAlign: TextAlign.center,
            style: tt.titleSmall?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppLocalizations.getString(context, 'appointments.searchHelp'),
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
