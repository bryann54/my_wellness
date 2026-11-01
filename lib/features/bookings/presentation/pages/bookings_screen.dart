import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_fab.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/error_state.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_card.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_detail/booking_empty_state.dart';

import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/bookings_list_skeleton.dart';

const double _loadMoreThreshold = 200.0;

@RoutePage()
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BookingsBloc>(),
      child: const BookingToastListener(child: _BookingsBody()),
    );
  }
}

class _BookingsBody extends StatefulWidget {
  const _BookingsBody();

  @override
  State<_BookingsBody> createState() => _BookingsBodyState();
}

class _BookingsBodyState extends State<_BookingsBody> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(const LoadMyBookingsEvent());
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - _loadMoreThreshold) {
      context.read<BookingsBloc>().add(const LoadMoreMyBookingsEvent());
    }
    return false;
  }

  Future<void> _refresh() async {
    final bloc = context.read<BookingsBloc>();
    bloc.add(const LoadMyBookingsEvent(refresh: true));
    await bloc.stream.firstWhere(
      (s) =>
          s.listStatus == BookingsListStatus.loaded ||
          s.listStatus == BookingsListStatus.error,
    );
  }

  Future<void> _newBooking() async {
    final type = await showModalBottomSheet<ServiceType>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in [
              ServiceType.navigator,
              ServiceType.screening,
              ServiceType.dnaTest,
              ServiceType.secondOpinion,
            ])
              ListTile(
                title: Text(
                  AppLocalizations.getString(
                    context,
                    'bookings.service.${t.name}',
                  ),
                ),
                onTap: () => Navigator.of(sheetCtx).pop(t),
              ),
          ],
        ),
      ),
    );
    if (type == null || !mounted) return;
    context.router.push(CreateBookingRoute(serviceType: type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppFab.extended(
         onPressed: _newBooking,
        icon: const Icon(Icons.add),
        label: AppLocalizations.getString(context, 'bookings.newBooking'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'bookings.title'),
            titleHeroTag: HeroTags.homeAppointments,
            isHome: false,
          ),
        ],
        body: BlocBuilder<BookingsBloc, BookingsState>(
          buildWhen: (p, c) =>
              p.listStatus != c.listStatus ||
              p.bookings != c.bookings ||
              p.listError != c.listError,
          builder: (context, state) {
            if (state.listStatus == BookingsListStatus.initial ||
                (state.listStatus == BookingsListStatus.loading &&
                    state.bookings.isEmpty)) {
              return const BookingsListSkeleton();
            }
            if (state.listStatus == BookingsListStatus.error &&
                state.bookings.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ErrorState(
                  message:
                      state.listError ??
                      AppLocalizations.getString(
                        context,
                        'common.errorGeneric',
                      ),
                  onRetry: () => context.read<BookingsBloc>().add(
                    const LoadMyBookingsEvent(refresh: true),
                  ),
                ),
              );
            }
            if (state.bookings.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: BookingEmptyState(onNewBooking: _newBooking),
              );
            }
            final loadingMore =
                state.listStatus == BookingsListStatus.loadingMore;
            return NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xxl * 2,
                  ),
                  itemCount: state.bookings.length + (loadingMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i >= state.bookings.length) {
                      return const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final b = state.bookings[i];
                    return BookingCard(
                      booking: b,
                      onTap: () => context.router.push(
                        BookingDetailRoute(bookingId: b.id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
