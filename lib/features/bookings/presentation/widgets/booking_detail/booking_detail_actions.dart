import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';

class BookingDetailActions extends StatelessWidget {
  final bool canComplete;
  final bool completing;
  final VoidCallback onComplete;

  const BookingDetailActions({
    super.key,
    required this.canComplete,
    required this.completing,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!canComplete) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: AppPrimaryButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onComplete();
        },
        label: AppLocalizations.getString(context, 'bookings.markCompleted'),
        isLoading: completing,
      ),
    );
  }
}
