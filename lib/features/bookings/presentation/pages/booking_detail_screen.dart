import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/constants/hero.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/error_state.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_detail/booking_detail_body.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_detail/booking_detail_skeleton.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_toast_listener.dart';

@RoutePage()
class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BookingsBloc>(),
      child: BookingToastListener(
        child: _BookingDetailBody(bookingId: bookingId),
      ),
    );
  }
}

class _BookingDetailBody extends StatefulWidget {
  final String bookingId;

  const _BookingDetailBody({required this.bookingId});

  @override
  State<_BookingDetailBody> createState() => _BookingDetailBodyState();
}

class _BookingDetailBodyState extends State<_BookingDetailBody> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(
      LoadBookingTimelineEvent(widget.bookingId),
    );
  }

  Future<void> _confirmComplete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.getString(context, 'bookings.completeConfirmTitle'),
        ),
        content: Text(
          AppLocalizations.getString(context, 'bookings.completeConfirmBody'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.getString(context, 'common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.getString(context, 'common.confirm')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<BookingsBloc>().add(CompleteBookingEvent(widget.bookingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          BlocBuilder<BookingsBloc, BookingsState>(
            buildWhen: (p, c) =>
                p.timeline?.booking.id != c.timeline?.booking.id,
            builder: (context, state) {
              final loadedId = state.timeline?.booking.id;
              return CustomAppBar(
                title: AppLocalizations.getString(
                  context,
                  'bookings.detailTitle',
                ),
                titleHeroTag: loadedId == widget.bookingId
                    ? HeroTags.bookingDetailAppBar(widget.bookingId)
                    : null,
                isHome: false,
              );
            },
          ),
        ],
        body: BlocBuilder<BookingsBloc, BookingsState>(
          buildWhen: (p, c) =>
              p.detailStatus != c.detailStatus ||
              p.timeline != c.timeline ||
              p.detailError != c.detailError ||
              p.completing != c.completing,
          builder: (context, state) {
            if (state.detailStatus == BookingDetailStatus.error) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BookingsBloc>().add(
                    LoadBookingTimelineEvent(widget.bookingId),
                  );
                },
                child: ErrorState(
                  message:
                      state.detailError ??
                      AppLocalizations.getString(
                        context,
                        'common.errorGeneric',
                      ),
                  onRetry: () => context.read<BookingsBloc>().add(
                    LoadBookingTimelineEvent(widget.bookingId),
                  ),
                ),
              );
            }
            final t = state.timeline;
            if (t == null || t.booking.id != widget.bookingId) {
              return const BookingDetailSkeleton();
            }
            final b = t.booking;
            final canComplete =
                !b.isHieManaged && t.isOwner && b.canBeManuallyCompleted;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookingsBloc>().add(
                  LoadBookingTimelineEvent(widget.bookingId),
                );
              },
              child: BookingDetailBody(
                timeline: t,
                canComplete: canComplete,
                completing: state.completing,
                onComplete: _confirmComplete,
              ),
            );
          },
        ),
      ),
    );
  }
}
