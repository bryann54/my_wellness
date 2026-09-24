import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';

class AssessmentsAccessGate extends StatelessWidget {
  final Widget child;
  const AssessmentsAccessGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

class AssessmentsBlockedView extends StatelessWidget {
  const AssessmentsBlockedView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 44, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.getString(context, 'assessment.noAccessTitle'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.getString(context, 'assessment.noAccessBody'),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
