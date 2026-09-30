import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/helpers/app_router.gr.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_compact_card.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/assessment_section_label.dart';
import 'package:my_wellness/features/assessments/presentation/widgets/category_header_icon.dart';

class AssessmentCategoryRail extends StatelessWidget {
  final String category;
  final List<AssessmentSummary> items;

  const AssessmentCategoryRail({
    super.key,
    required this.category,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.forCategory(category);
    final label = style.localizedLabel(context, category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssessmentSectionLabel(
          label,
          leading: CategoryHeaderIcon(style: style),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: AssessmentCompactCard.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final a = items[i];
              return AssessmentCompactCard(
                summary: a,
                onTap: () =>
                    context.router.push(AssessmentIntroRoute(slug: a.slug)),
              );
            },
          ),
        ),
      ],
    );
  }
}
