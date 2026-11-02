import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';

class AssessmentBlockedView extends StatelessWidget {
  final AssessmentsState state;
  final VoidCallback? onResumeBlocking;

  const AssessmentBlockedView({
    super.key,
    required this.state,
    this.onResumeBlocking,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String title;
    String body;
    String? actionLabel;
    VoidCallback? onAction;
    String? dependantLabel;

    switch (state.block) {
      case AssessmentBlockKind.ageIneligible:
        title = AppLocalizations.getString(
          context,
          'assessment.blocked.ageIneligible.title',
        );
        body = AppLocalizations.getString(
          context,
          'assessment.blocked.ageIneligible.body',
        );
        actionLabel = null;
        onAction = null;
      case AssessmentBlockKind.genderIneligible:
        title = AppLocalizations.getString(
          context,
          'assessment.blocked.genderIneligible.title',
        );
        body = AppLocalizations.getString(
          context,
          'assessment.blocked.genderIneligible.body',
        );
        if (state.dependantVariantSlug != null) {
          dependantLabel = AppLocalizations.getString(
            context,
            'assessment.blocked.genderIneligible.actionOpenDependant',
          );
        }
        actionLabel = null;
        onAction = null;
      case AssessmentBlockKind.cancerDiagnosedBlocked:
        title = AppLocalizations.getString(
          context,
          'assessment.blocked.cancerDiagnosedBlocked.title',
        );
        body = AppLocalizations.getString(
          context,
          'assessment.blocked.cancerDiagnosedBlocked.body',
        );
        actionLabel = null;
        onAction = null;
      case AssessmentBlockKind.dependantConsentRequired:
        title = AppLocalizations.getString(
          context,
          'assessment.blocked.dependantConsentRequired.title',
        );
        body = AppLocalizations.getString(
          context,
          'assessment.blocked.dependantConsentRequired.body',
        );
        actionLabel = null;
        onAction = null;
      case AssessmentBlockKind.assessmentInProgress:
        title = AppLocalizations.getString(
          context,
          'assessment.blocked.assessmentInProgress.title',
        );
        final priorTitle = state.blockingTitle;
        body = priorTitle != null
            ? AppLocalizations.t(
                context,
                'assessment.blocked.assessmentInProgress.body',
                {'title': priorTitle},
              )
            : AppLocalizations.getString(
                context,
                'assessment.blocked.assessmentInProgress.bodyFallback',
              );
        if (priorTitle != null) {
          actionLabel = AppLocalizations.t(
            context,
            'assessment.blocked.assessmentInProgress.resumeAction',
            {'title': priorTitle},
          );
        } else {
          actionLabel = AppLocalizations.getString(
            context,
            'assessment.blocked.assessmentInProgress.resumeActionFallback',
          );
        }
        onAction = onResumeBlocking;
      case AssessmentBlockKind.none:
        title = '';
        body = '';
        actionLabel = null;
        onAction = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.getString(context, 'assessment.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.info_outline, size: 48, color: cs.primary),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              if (dependantLabel != null)
                AppPrimaryButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  label: dependantLabel,
                  height: 52,
                ),
              if (actionLabel != null && onAction != null) ...[
                AppPrimaryButton(
                  onPressed: onAction,
                  label: actionLabel,
                  height: 52,
                ),
                const SizedBox(height: 12),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(AppLocalizations.getString(context, 'common.back')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
