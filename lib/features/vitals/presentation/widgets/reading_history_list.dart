import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/common/widgets/custom_alert_dialog.dart';
import 'package:my_wellness/features/home/presentation/widgets/vitals_status_pill.dart';

class ReadingHistoryRow {
  final String id;
  final String primary;
  final String unit;
  final String classification;
  final String timestampIso;
  final String? secondary;
  final VoidCallback onDelete;

  const ReadingHistoryRow({
    required this.id,
    required this.primary,
    required this.unit,
    required this.classification,
    required this.timestampIso,
    this.secondary,
    required this.onDelete,
  });
}

class ReadingHistoryList extends StatelessWidget {
  final List<ReadingHistoryRow> readings;
  const ReadingHistoryList({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.lgAll,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < readings.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              _HistoryItem(row: readings[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.row});

  final ReadingHistoryRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tone = VitalsStatusPill.toneFor(row.classification);
    final (toneColor, _) = VitalsStatusPill.colorsFor(tone, theme);

    return Dismissible(
      key: ValueKey(row.id),
      direction: DismissDirection.endToStart,
      // Medical records: never delete on a stray swipe.
      confirmDismiss: (_) async {
        final ok = await AppDialogs.ask(
          context,
          title: AppLocalizations.getString(
            context,
            'vitals.deleteConfirmTitle',
          ),
          message: AppLocalizations.getString(
            context,
            'vitals.deleteConfirmMessage',
          ),
          isDestructive: true,
        );
        return ok ?? false;
      },
      onDismissed: (_) => row.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: cs.error,
        child: Icon(Icons.delete_outline_rounded, color: cs.onError),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: toneColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: toneColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          row.primary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        row.unit,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    friendlyDateTime(row.timestampIso),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (row.secondary != null)
                    Text(
                      row.secondary!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            VitalsStatusPill(classification: row.classification, compact: true),
          ],
        ),
      ),
    );
  }
}
