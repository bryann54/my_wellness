import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssessmentProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final String? section;

  const AssessmentProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(cs.primary),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (section != null)
              Expanded(
                child: Text(
                  section!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              const Spacer(),
            Text(
              '${current + 1} of $total',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
