import 'package:flutter/material.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/referral.dart';
import 'package:my_wellness/features/assessments/presentation/pages/assessment_result_screen.dart';

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
    return AssessmentResultScreen(slug: slug);
  }
}
