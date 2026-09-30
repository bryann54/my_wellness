import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_category_rail.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_section_label.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/category_header_icon.dart';

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
    final rest = hasRecommended ? assessments.sublist(1) : assessments;

    // Bucket by category.
    final grouped = <String, List<AssessmentSummary>>{};
    for (final a in rest) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }
    final categories = grouped.keys.toList(growable: false);

    // Number of vertical "rows" in the outer list.
    // +1 for the recommended block, +1 for the gap before the first rail.
    final int recommendedBlocks = hasRecommended ? 1 : 0;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: recommendedBlocks + categories.length,
      itemBuilder: (context, index) {
        // ── Recommended card ─────────────────────────────────────────
        if (hasRecommended && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  statusLabel: AppLocalizations.getString(
                    context,
                    'assessment.recommendedPill',
                  ),
                  onTap: () => context.router.push(
                    AssessmentIntroRoute(slug: recommended.slug),
                  ),
                ),
              ],
            ),
          );
        }

        final category = categories[index - recommendedBlocks];
        final items = grouped[category]!;
        if (items.length == 1) {
          final only = items.first;
          final style = CategoryStyle.forCategory(category);
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssessmentSectionLabel(
                  style.localizedLabel(context, category),
                  leading: CategoryHeaderIcon(style: style),
                ),
                const SizedBox(height: 10),
                AssessmentCard(
                  summary: only,
                  onTap: () => context.router.push(
                    AssessmentIntroRoute(slug: only.slug),
                  ),
                ),
              ],
            ),
          );
        }

        // Multi-item → horizontal rail.
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AssessmentCategoryRail(category: category, items: items),
        );
      },
    );
  }
}
