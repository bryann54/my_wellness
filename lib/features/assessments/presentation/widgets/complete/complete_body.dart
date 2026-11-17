import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_findings.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_footer.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_hero.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_next_step.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_report_card.dart';
import 'package:my_wellness/features/bookings/domain/entities/service_booking.dart';

class CompleteBody extends StatelessWidget {
  final String slug;
  final AssessmentScore score;
  final AssessmentSession? session;
  final Referral? referral;
  final String? categoryRaw;
  final AssessmentDefinition? definition;
  final CanStartResult? canStart;
  final bool downloading;
  final bool emailing;

  const CompleteBody({
    super.key,
    required this.slug,
    required this.score,
    required this.session,
    this.referral,
    this.categoryRaw,
    this.definition,
    this.canStart,
    this.downloading = false,
    this.emailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final display = score.resultDisplay;
    final category = categoryRaw?.trim().toLowerCase();
    final isCancer = category == 'cancer';
    final showHero = !isCancer && category != 'reproductive health';
    final showReport = (display?.showReportCard ?? false) || isCancer;
    final showFooterTiles =
        display?.kind == 'endometriosis' && (display?.showFooterTiles ?? false);
    final canRetake = canStart?.allowed ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToAssessments(context);
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [
            CustomAppBar(
              title:
                  definition?.shortTitle ??
                  AppLocalizations.getString(context, 'assessment.title'),
              isHome: false,
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              if (showHero) ...[
                CompleteHero(
                  reference: session?.referenceNumber,
                  categoryRaw: categoryRaw,
                ),
                const SizedBox(height: 24),
              ],
              CompleteFindings(
                score: score,
                onPrimaryCta: () => _openNavigator(
                  context,
                  display?.primaryCtaLabel ??
                      AppLocalizations.getString(
                        context,
                        'assessment.endometriosisNavigation',
                      ),
                ),
                onSecondaryCta: () {
                  // TODO: Route to Endometriosis Learn More (help tab)
                },
              ),
              if (referral != null) ...[
                const SizedBox(height: 24),
                CompleteNextStep(
                  referral: referral,
                  onBook: () => _openFacilityFinder(context, score),
                ),
              ],
              if (showReport) ...[
                const SizedBox(height: 24),
                CompleteReportCard(
                  downloading: downloading,
                  emailing: emailing,
                  onDownload: () => context.read<AssessmentsBloc>().add(
                    const DownloadReportEvent(),
                  ),
                  onEmail: () => _promptEmail(context),
                  onShare: () => _promptEmail(context, forProvider: true),
                ),
              ],
              if (showFooterTiles) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Route to Endometriosis Learn More
                        },
                        style: _outlinedStyle(cs),
                        child: Text(
                          AppLocalizations.getString(
                            context,
                            'assessment.learnEndometriosis',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openNavigator(
                          context,
                          AppLocalizations.getString(
                            context,
                            'assessment.endometriosisNavigation',
                          ),
                        ),
                        style: _outlinedStyle(cs),
                        child: Text(
                          AppLocalizations.getString(
                            context,
                            'assessment.careSupport',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (canRetake) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _retake(context),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    AppLocalizations.getString(context, 'assessment.retake'),
                  ),
                  style: _outlinedStyle(cs),
                ),
              ],
              const SizedBox(height: 24),
              CompleteFooter(
                onRate: () {},
                onDashboard: () => context.router.popUntilRoot(),
                onTakeAnother: () => _goToAssessments(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _outlinedStyle(ColorScheme cs) => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    foregroundColor: cs.onSurface,
    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
  );

  void _goToAssessments(BuildContext context) {
    final router = context.router;
    final inStack = router.stack.any(
      (p) => p.routeData.name == AssessmentsListRoute.name,
    );
    if (inStack) {
      router.popUntilRouteWithName(AssessmentsListRoute.name);
    } else {
      router.replace(const AssessmentsListRoute());
    }
  }

  void _retake(BuildContext context) {
    context.read<AssessmentsBloc>().add(const ResetAssessmentsEvent());
    context.router.replace(AssessmentIntroRoute(slug: slug));
  }

  void _openNavigator(BuildContext context, String label) {
    context.router.push(
      CreateBookingRoute(
        serviceType: ServiceType.navigator,
        serviceLabel: label,
      ),
    );
  }

  void _openFacilityFinder(BuildContext context, AssessmentScore score) {
    context.router.push(
      CreateBookingRoute(
        serviceType: ServiceType.checkup,
        serviceLabel: score.resultDisplay?.primaryCtaLabel,
      ),
    );
  }

  Future<void> _promptEmail(
    BuildContext context, {
    bool forProvider = false,
  }) async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(
          AppLocalizations.getString(
            context,
            forProvider
                ? 'assessment.shareProviderTitle'
                : 'assessment.emailReport',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.getString(
                context,
                forProvider
                    ? 'assessment.shareProviderBody'
                    : 'assessment.emailReportBody',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.getString(
                  context,
                  forProvider ? 'assessment.providerEmail' : 'auth.email',
                ),
                hintText: forProvider ? 'doctor@clinic.com' : 'you@example.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.getString(context, 'common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              AppLocalizations.getString(context, 'assessment.sendReport'),
            ),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty || !context.mounted) return;
    context.read<AssessmentsBloc>().add(
      DownloadReportEvent(email: email, emailOnly: true),
    );
  }
}
