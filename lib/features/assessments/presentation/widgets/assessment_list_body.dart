import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_section_label.dart';

class AssessmentListBody extends StatelessWidget {
  final List<AssessmentSummary> assessments;
  final String searchQuery;

  const AssessmentListBody({
    super.key,
    required this.assessments,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.trim().isNotEmpty;
    final hasRecommended = !isSearching && assessments.isNotEmpty;
    final recommended = hasRecommended ? assessments.first : null;
    final remaining = hasRecommended ? assessments.skip(1) : assessments;

    final grouped = <String, List<AssessmentSummary>>{};
    for (final assessment in remaining) {
      grouped.putIfAbsent(assessment.category, () => []).add(assessment);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        if (hasRecommended) ...[
          AssessmentSectionLabel(
            AppLocalizations.getString(
              context,
              'assessment.forYouSectionTitle',
            ),
          ),
          const SizedBox(height: 10),
          AssessmentCard(
            summary: recommended!,
            isRecommended: true,
            onTap: () => context.router.push(
              AssessmentIntroRoute(slug: recommended.slug),
            ),
          ),
          const SizedBox(height: 28),
        ],
        for (final entry in grouped.entries) ...[
          AssessmentSectionLabel(
            CategoryStyle.forCategory(
              entry.key,
            ).localizedLabel(context, entry.key),
          ),
          const SizedBox(height: 10),
          for (final assessment in entry.value) ...[
            AssessmentCard(
              summary: assessment,
              onTap: () => context.router.push(
                AssessmentIntroRoute(slug: assessment.slug),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
