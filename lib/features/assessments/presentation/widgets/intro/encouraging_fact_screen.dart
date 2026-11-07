import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';

class EncouragingFactScreen extends StatelessWidget {
  final String slug;
  final String fact;
  final String shortTitle;
  final VoidCallback onContinue;

  const EncouragingFactScreen({
    super.key,
    required this.slug,
    required this.fact,
    required this.shortTitle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 28,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.getString(
                          context,
                          'assessment.encouragingFact',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fact,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                onPressed: onContinue,
                label: AppLocalizations.getString(context, 'common.continue'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  '← ${AppLocalizations.getString(context, 'assessment.backToInstructions')}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
