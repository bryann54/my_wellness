import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepProgress extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;
  final String? label;

  const StepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = (currentStep / totalSteps).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: cs.surfaceContainerHighest,
            color: cs.primary,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
