import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/features/bookings/domain/entities/booking_timeline.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_detail/booking_detail_actions.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_detail/booking_detail_hero.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/booking_detail/booking_detail_timeline.dart';

class BookingDetailBody extends StatelessWidget {
  final BookingTimeline timeline;
  final bool canComplete;
  final bool completing;
  final VoidCallback onComplete;

  const BookingDetailBody({
    super.key,
    required this.timeline,
    required this.canComplete,
    required this.completing,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        BookingDetailHero(booking: timeline.booking),
        const SizedBox(height: AppSpacing.md),
        BookingDetailActions(
          canComplete: canComplete,
          completing: completing,
          onComplete: onComplete,
        ),
        const SizedBox(height: AppSpacing.lg),
        BookingDetailTimeline(entries: timeline.timeline),
      ],
    );
  }
}
