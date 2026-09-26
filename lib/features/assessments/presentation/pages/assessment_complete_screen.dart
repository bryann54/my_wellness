import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_toast_listener.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_bottom_actions.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_facility_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_loading.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_rating_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_recommended_care.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_report_actions.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_result_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_score_recommendations.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_symptom_alerts.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_thank_you_banner.dart';

@RoutePage()
class AssessmentCompleteScreen extends StatelessWidget {
  final String slug;
  const AssessmentCompleteScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AssessmentsBloc>(),
      child: AssessmentToastListener(
        child: _AssessmentCompleteBody(slug: slug),
      ),
    );
  }
}

class _AssessmentCompleteBody extends StatefulWidget {
  final String slug;
  const _AssessmentCompleteBody({required this.slug});

  @override
  State<_AssessmentCompleteBody> createState() =>
      _AssessmentCompleteBodyState();
}

class _AssessmentCompleteBodyState extends State<_AssessmentCompleteBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AssessmentsBloc>();
      // Only fetch if we somehow arrived without a score. Normal flow
    
      if (bloc.state.score == null || !bloc.state.completionHandled) {
        bloc.add(const FetchScoreEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AssessmentsBloc>().state;
    final score = state.score;
    final session = state.session;
    final referral = state.referral;
    final def = state.definition;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          CustomAppBar(
            title: AppLocalizations.getString(
              context,
              'assessment.completeTitle',
            ),
            isHome: false,
          ),
        ],
        body: score == null
            ? const CompleteLoading()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompleteThankYouBanner(
                      reference: session?.referenceNumber,
                      categoryRaw: def?.category,
                    ),
                    const SizedBox(height: 20),
                    CompleteResultCard(score: score),
                    if (referral != null) ...[
                      const SizedBox(height: 20),
                      CompleteRecommendedCare(referral: referral),
                      if (referral.recommendedFacility != null) ...[
                        const SizedBox(height: 12),
                        CompleteFacilityCard(
                          facility: referral.recommendedFacility!,
                          reason: referral.reason,
                          onBook: () {
                            // TODO: booking flow
                          },
                        ),
                      ],
                    ],
                    if (score.recommendations.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      CompleteScoreRecommendations(
                        recommendations: score.recommendations,
                      ),
                    ],
                    if (score.symptomAlerts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      CompleteSymptomAlerts(alerts: score.symptomAlerts),
                    ],
                    const SizedBox(height: 20),
                    CompleteReportActions(
                      onRetake: () {
                        context.router.replace(
                          AssessmentIntroRoute(slug: widget.slug),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const CompleteRatingCard(),
                    const SizedBox(height: 24),
                    CompleteBottomActions(
                      onDashboard: () => context.router.popUntilRoot(),
                      onMoreAssessments: () =>
                          context.router.replace(const AssessmentsListRoute()),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
