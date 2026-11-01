import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/section_label.dart';
import 'package:my_wellness/features/bookings/domain/entities/booking_timeline.dart';

class BookingDetailTimeline extends StatelessWidget {
  final List<TimelineEntry> entries;

  const BookingDetailTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          AppLocalizations.getString(context, 'bookings.timelineTitle'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              AppLocalizations.getString(context, 'bookings.timelineEmpty'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < entries.length; i++)
                  _TimelineTile(
                    entry: entries[i],
                    isLast: i == entries.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final TimelineEntry entry;
  final bool isLast;

  const _TimelineTile({required this.entry, required this.isLast});

  String _title(BuildContext context) {
    if (entry.type == 'event') {
      return AppLocalizations.getString(
        context,
        'bookings.timeline.${switch (entry.eventType) {
          'created' => 'created',
          'checked_in' => 'checkedIn',
          'status_changed' => 'statusChanged',
          'follow_up_scheduled' => 'followUpScheduled',
          _ => 'update',
        }}',
      );
    }
    return AppLocalizations.getString(
      context,
      'bookings.timeline.${switch (entry.type) {
        'note' => 'note',
        'diagnosis' => 'diagnosis',
        'allergy' => 'allergy',
        'prescription' => 'prescription',
        'referral' => 'referral',
        _ => 'update',
      }}',
    );
  }

  String? _subtitle() {
    if (entry.eventType == 'status_changed') {
      final meta = entry.data['metadata'];
      if (meta is Map) return '${meta['from']} → ${meta['to']}';
    }
    return entry.text;
  }

  IconData _icon() => switch (entry.eventType) {
    'checked_in' => Icons.login_outlined,
    'status_changed' => Icons.swap_horiz_rounded,
    'follow_up_scheduled' => Icons.schedule_outlined,
    'note' => Icons.sticky_note_2_outlined,
    'diagnosis' => Icons.medical_services_outlined,
    'allergy' => Icons.warning_amber_rounded,
    'prescription' => Icons.medication_outlined,
    'referral' => Icons.call_split_rounded,
    _ => Icons.circle_outlined,
  };

  Color _accent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (entry.eventType) {
      'checked_in' => const Color(0xFF10B981),
      'status_changed' => const Color(0xFF3B82F6),
      'follow_up_scheduled' => const Color(0xFFF59E0B),
      'allergy' => cs.error,
      _ => cs.primary,
    };
  }

  String _stamp(DateTime d) {
    final dt = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _accent(context);
    final subtitle = _subtitle();

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(), size: 14, color: accent),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title(context), style: theme.textTheme.titleSmall),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (entry.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _stamp(entry.createdAt!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
