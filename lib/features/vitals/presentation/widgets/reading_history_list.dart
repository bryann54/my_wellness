import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/utils/formatters.dart';
import 'package:my_wellness/features/vitals/presentation/utils/classification_colors.dart';

class ReadingHistoryRow {
  final String id;
  final String primary;
  final String unit;
  final String classification;
  final String timestampIso;
  final VoidCallback onDelete;

  const ReadingHistoryRow({
    required this.id,
    required this.primary,
    required this.unit,
    required this.classification,
    required this.timestampIso,
    required this.onDelete,
  });
}

class ReadingHistoryList extends StatelessWidget {
  final List<ReadingHistoryRow> readings;
  const ReadingHistoryList({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: readings.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 60,
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, i) {
          final r = readings[i];
          final color = classificationColor(r.classification);
          return Dismissible(
            key: ValueKey(r.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => r.onDelete(),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: cs.error.withValues(alpha: 0.85),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    r.primary,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    r.unit,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                friendlyDateTime(r.timestampIso),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
