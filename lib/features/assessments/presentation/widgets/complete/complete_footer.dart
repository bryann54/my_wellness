import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class CompleteFooter extends StatelessWidget {
  final VoidCallback onDashboard;
  final VoidCallback onTakeAnother;
  final VoidCallback onRate;

  const CompleteFooter({
    super.key,
    required this.onDashboard,
    required this.onTakeAnother,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onDashboard,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: cs.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppLocalizations.getString(context, 'assessment.goToDashboard'),
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onTakeAnother,
          child: Text(
            AppLocalizations.getString(context, 'assessment.moreAssessments'),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextButton(
          onPressed: onRate,
          child: Text(
            AppLocalizations.getString(context, 'assessment.rateThisScreening'),
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
