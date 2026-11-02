import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';

class BookingsEmptyState extends StatelessWidget {
  final String query;
  final bool isSearching;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  const BookingsEmptyState({
    super.key,
    required this.query,
    required this.isSearching,
    required this.onClear,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final title = isSearching
        ? AppLocalizations.t(context, 'bookings.emptySearchTitle', {
            'query': query,
          })
        : AppLocalizations.getString(context, 'bookings.emptyTitle');
    final body = AppLocalizations.getString(
      context,
      isSearching ? 'bookings.emptySearchBody' : 'bookings.emptyBody',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.event_note_outlined,
            size: 48,
            color: cs.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: tt.titleSmall?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isSearching)
            TextButton(
              onPressed: onClear,
              child: Text(
                AppLocalizations.getString(
                  context,
                  'bookings.emptySearchClear',
                ),
              ),
            )
          else
            AppPrimaryButton(
              onPressed: onCreate,
              label: AppLocalizations.getString(context, 'bookings.newBooking'),
            ),
        ],
      ),
    );
  }
}
