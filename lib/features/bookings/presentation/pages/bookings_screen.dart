import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/debouncer.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/bookig_empty_state.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_card.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_section_label.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/bookings_list_skeleton.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/bookings_search_bar_bottom.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/new_booking_sheet.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/refferal_card.dart';

const double _hPad = AppSpacing.md + AppSpacing.xs;

@RoutePage()
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BookingsBloc>(),
      child: const BookingsToastListener(child: _BookingsBody()),
    );
  }
}

class _BookingsBody extends StatefulWidget {
  const _BookingsBody();

  @override
  State<_BookingsBody> createState() => _BookingsBodyState();
}

class _BookingsBodyState extends State<_BookingsBody> {
  final _searchDebouncer = Debouncer(milliseconds: 250);
  final _paginationDebouncer = Debouncer(milliseconds: 200);
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<BookingsBloc>();
    bloc.add(const SearchBookingsEvent(''));
    bloc.add(const LoadMyBookingsEvent());
    bloc.add(const LoadMyReferralsEvent());
  }

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _paginationDebouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _searchDebouncer.run(() {
      if (!mounted) return;
      context.read<BookingsBloc>().add(SearchBookingsEvent(q));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebouncer.cancel();
    context.read<BookingsBloc>().add(const SearchBookingsEvent(''));
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical || n.metrics.extentAfter > 300) {
      return false;
    }
    _paginationDebouncer.run(() {
      if (!mounted) return;
      final bloc = context.read<BookingsBloc>();
      if (bloc.state.hasMore &&
          bloc.state.listStatus == BookingsListStatus.loaded) {
        bloc.add(const LoadMoreMyBookingsEvent());
      }
    });
    return false;
  }

  Future<void> _refresh() async {
    final bloc = context.read<BookingsBloc>();
    bloc.add(const LoadMyBookingsEvent(refresh: true));
    bloc.add(const LoadMyReferralsEvent(refresh: true));
    await bloc.stream
        .firstWhere(
          (s) =>
              s.listStatus == BookingsListStatus.loaded ||
              s.listStatus == BookingsListStatus.error,
        )
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  Future<void> _newBooking() async {
    final type = await NewBookingSheet.show(context);
    if (type == null || !mounted) return;
    context.router.push(CreateBookingRoute(serviceType: type));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newBooking,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppLocalizations.getString(context, 'bookings.newBooking')),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          CustomAppBar(
            title: AppLocalizations.getString(context, 'bookings.title'),
            isHome: false,
            isTabRoot: true,
            bottom: BookingsSearchBarBottom(
              controller: _searchController,
              hintText: AppLocalizations.getString(
                context,
                'bookings.searchHint',
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ],
        body: BlocBuilder<BookingsBloc, BookingsState>(
          buildWhen: (p, c) =>
              p.listStatus != c.listStatus ||
              p.bookings != c.bookings ||
              p.searchQuery != c.searchQuery ||
              p.listError != c.listError ||
              p.referrals != c.referrals,
          builder: _buildContent,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookingsState state) {
    final loadingInitial =
        state.listStatus == BookingsListStatus.initial ||
        (state.listStatus == BookingsListStatus.loading &&
            state.bookings.isEmpty);
    if (loadingInitial) return const BookingsListSkeleton();

    if (state.listStatus == BookingsListStatus.error &&
        state.bookings.isEmpty) {
      return _ErrorView(
        message:
            state.listError ??
            AppLocalizations.getString(context, 'bookings.loadFailed'),
        onRetry: () => context.read<BookingsBloc>().add(
          const LoadMyBookingsEvent(refresh: true),
        ),
      );
    }

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final query = state.searchQuery;
    final isSearching = query.isNotEmpty;
    final items = state.filteredBookings;
    final referrals = isSearching
        ? const <Referral>[]
        : state.referrals
              .where((r) => r.status != ReferralStatus.dismissed)
              .take(10)
              .toList(growable: false);
    final loadingMore = state.listStatus == BookingsListStatus.loadingMore;

    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (referrals.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md - 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _hPad),
                        child: BookingSectionLabel(
                          AppLocalizations.getString(
                            context,
                            'bookings.referral.section',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm + 2),
                      SizedBox(
                        height: ReferralCard.height,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: _hPad,
                          ),
                          itemCount: referrals.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.sm + 4),
                          itemBuilder: (context, i) => ReferralCard(
                            referral: referrals[i],
                            onTap: () => context.router.push(
                              ReferralDetailRoute(referralId: referrals[i].id),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            if (isSearching && items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(_hPad, 4, _hPad, 8),
                  child: Text(
                    items.length == 1
                        ? AppLocalizations.t(
                            context,
                            'bookings.searchResultCountOne',
                            {'query': query},
                          )
                        : AppLocalizations.t(
                            context,
                            'bookings.searchResultCountMany',
                            {'count': '${items.length}', 'query': query},
                          ),
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: BookingsEmptyState(
                    query: query,
                    isSearching: isSearching,
                    onClear: _clearSearch,
                    onCreate: _newBooking,
                  ),
                ),
              )
            else ...[
              if (!isSearching)
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
                        'bookings.yourBookings',
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: _hPad),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => BookingCard(booking: items[i]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: 96,
                  ),
                  child: loadingMore
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            AppPrimaryButton(
              onPressed: onRetry,
              label: AppLocalizations.getString(context, 'common.retry'),
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
