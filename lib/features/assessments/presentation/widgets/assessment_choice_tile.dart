import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_option.dart';

class AssessmentChoiceTile extends StatelessWidget {
  static const warm = Color(0xFFF59E0B);

  final AssessmentOption option;
  final bool selected;
  final VoidCallback onTap;

  const AssessmentChoiceTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? warm.withValues(alpha: 0.10) : cs.surface,
          border: Border.all(
            color: selected ? warm : cs.outlineVariant.withValues(alpha: 0.6),
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? warm : Colors.transparent,
                border: Border.all(
                  color: selected ? warm : Colors.grey.shade400,
                  width: 1.6,
                ),
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.circle, size: 8, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.label,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
