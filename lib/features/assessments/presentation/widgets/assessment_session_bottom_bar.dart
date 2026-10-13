// lib/features/assessments/presentation/widgets/assessment_session_bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class AssessmentSessionBottomBar extends StatelessWidget {
  final bool canProceed;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const AssessmentSessionBottomBar({
    super.key,
    required this.canProceed,
    required this.submitting,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left, size: 18),
            label: Text(
              AppLocalizations.getString(context, 'common.back'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
               minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
              foregroundColor: cs.onSurface,
            ),
          ),
          FilledButton.icon(
            onPressed: (canProceed && !submitting) ? onNext : null,
            iconAlignment: IconAlignment.end,
            icon: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right, size: 18),
            label: Text(
              AppLocalizations.getString(context, 'common.next'),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
               minimumSize: const Size(0, 48),
              backgroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
