import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';

class BookingEmptyState extends StatelessWidget {
  final VoidCallback onNewBooking;

  const BookingEmptyState({super.key, required this.onNewBooking});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 80,
        horizontal: AppSpacing.xl,
      ),
      children: [
        Icon(
          Icons.event_available_outlined,
          size: 48,
          color: cs.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppLocalizations.getString(context, 'bookings.emptyTitle'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppLocalizations.getString(context, 'bookings.emptyBody'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SizedBox(
            width: 220,
            child: AppPrimaryButton(
              onPressed: onNewBooking,
              label: AppLocalizations.getString(context, 'bookings.newBooking'),
            ),
          ),
        ),
      ],
    );
  }
}
