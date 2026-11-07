import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/app_primary_button.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';

class PlainIntroCard extends StatelessWidget {
  final String slug;
  final AssessmentSession session;
  final AssessmentDefinition definition;
  final CanStartResult? canStart;

  const PlainIntroCard({
    super.key,
    required this.slug,
    required this.session,
    required this.definition,
    this.canStart,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locked = session.status == AssessmentSessionStatus.awaitingPayment;
    final awaitingCall = session.status == AssessmentSessionStatus.awaitingCall;
    final cooldown = canStart != null && !canStart!.allowed;
    final chapterLocked = canStart?.isChapterLocked ?? false;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _BackLink(label: definition.category),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      definition.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    definition.title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    definition.tagline,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      height: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.timer_outlined,
                        label: AppLocalizations.getString(
                          context,
                          'assessment.takesFiveToTen',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.lock_outline,
                        label: AppLocalizations.getString(
                          context,
                          'assessment.confidential',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.picture_as_pdf_outlined,
                        label: AppLocalizations.getString(
                          context,
                          'assessment.pdfReport',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (chapterLocked)
              _NotYetAvailablePanel(
                priorTitle: canStart?.priorTitle,
                lastCompletedAt: canStart?.lastCompletedAt,
                nextEligibleAt: canStart?.nextEligibleAt,
              )
            else if (cooldown)
              _ReassessmentPanel(canStart: canStart!)
            else if (locked)
              _LockedCard(definition: definition, session: session)
            else if (awaitingCall)
              _AwaitingCallCard(session: session)
            else
              AppPrimaryButton(
                onPressed: () =>
                    context.router.push(AssessmentSessionRoute(slug: slug)),
                label: session.currentIndex > 0
                    ? 'Resume assessment'
                    : 'Start assessment',
              ),
            if (definition.disclaimer != null) ...[
              const SizedBox(height: 16),
              Text(
                'Disclaimer. ${definition.disclaimer}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackLink extends StatelessWidget {
  final String label;
  const _BackLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chevron_left, size: 18),
            const SizedBox(width: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: cs.onSurface.withValues(alpha: 0.55)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotYetAvailablePanel extends StatelessWidget {
  final String? priorTitle;
  final String? lastCompletedAt;
  final String? nextEligibleAt;

  const _NotYetAvailablePanel({
    this.priorTitle,
    this.lastCompletedAt,
    this.nextEligibleAt,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final message = priorTitle != null
        ? '${priorTitle!} was completed on ${_fmt(lastCompletedAt)}. '
              'This session unlocks on ${_fmt(nextEligibleAt)}.'
        : 'Complete ${priorTitle ?? 'the previous session'} first to unlock '
              'this session.';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_clock_outlined, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: cs.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(String? iso) {
    if (iso == null) return 'an earlier date';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return iso;
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _ReassessmentPanel extends StatelessWidget {
  final CanStartResult canStart;
  const _ReassessmentPanel({required this.canStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Re-assessment available later',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You completed this assessment on ${_fmt(canStart.lastCompletedAt)}. '
            'You can retake it from ${_fmt(canStart.nextEligibleAt)}.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(String? iso) {
    if (iso == null) return 'an earlier date';
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return iso;
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _LockedCard extends StatelessWidget {
  final AssessmentDefinition definition;
  final AssessmentSession session;
  const _LockedCard({required this.definition, required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.getString(context, 'assessment.lockedTitle'),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.t(context, 'assessment.lockedBody', {
              'category': definition.category,
            }),
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => context.router.push(PricingRoute()),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            iconAlignment: IconAlignment.end,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: Text(
              AppLocalizations.getString(context, 'assessment.unlockMpesa'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AwaitingCallCard extends StatelessWidget {
  final AssessmentSession session;
  const _AwaitingCallCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment received',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            session.navigatorAlertedAt == null
                ? "When you're ready to complete this assessment over the "
                      'phone, let our team know.'
                : 'A member of our team will call you within one business '
                      'day to complete this for you over the phone.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
