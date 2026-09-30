import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_findings.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_hero.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_next_step.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/complete/complete_footer.dart';

class CompleteBody extends StatelessWidget {
  final String slug;
  final AssessmentScore score;
  final AssessmentSession? session;
  final Referral? referral;
  final String? categoryRaw;

  const CompleteBody({
    super.key,
    required this.slug,
    required this.score,
    required this.session,
    this.referral,
    this.categoryRaw,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            CompleteHero(
              reference: session?.referenceNumber,
              categoryRaw: categoryRaw,
            ),
            const SizedBox(height: 24),
            CompleteFindings(score: score),
            const SizedBox(height: 24),
            CompleteNextStep(
              referral: referral,
              onBook: () {
                // TODO: booking flow
              },
            ),
            const SizedBox(height: 32),
            CompleteFooter(
              onDashboard: () => context.router.popUntilRoot(),
              onTakeAnother: () =>
                  context.router.replace(const AssessmentsListRoute()),
              onRate: () {
                // TODO: open rating sheet
              },
            ),
          ],
        ),
      ),
    );
  }
}
