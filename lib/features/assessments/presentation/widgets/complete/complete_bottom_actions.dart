import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class CompleteBottomActions extends StatelessWidget {
  final VoidCallback onDashboard;
  final VoidCallback onMoreAssessments;

  const CompleteBottomActions({
    super.key,
    required this.onDashboard,
    required this.onMoreAssessments,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _SecondaryButton(
            label: AppLocalizations.getString(
              context,
              'assessment.goToDashboard',
            ),
            onTap: onDashboard,
            colorScheme: cs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SecondaryButton(
            label: AppLocalizations.getString(
              context,
              'assessment.moreAssessments',
            ),
            onTap: onMoreAssessments,
            colorScheme: cs,
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _SecondaryButton({
    required this.label,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        foregroundColor: colorScheme.onSurface,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}
