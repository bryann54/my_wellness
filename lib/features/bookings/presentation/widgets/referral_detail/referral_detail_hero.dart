import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/features/bookings/domain/entities/referral.dart';
import 'package:my_wellness/features/bookings/presentation/widgets/status_chip.dart';

class ReferralDetailHero extends StatelessWidget {
  final Referral referral;

  const ReferralDetailHero({super.key, required this.referral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  referral.escalationCategoryDisplay,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip.referral(context, referral.status),
            ],
          ),
          if (referral.reason.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              referral.reason,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
          if (referral.requiredServices.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final s in referral.requiredServices)
                  _ServiceChip(label: s.name),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  const _ServiceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
