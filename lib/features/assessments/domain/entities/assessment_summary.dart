import 'package:equatable/equatable.dart';

class AssessmentSummary extends Equatable {
  final String slug;
  final String category;
  final String title;
  final String shortTitle;
  final String tagline;
  final String? excludedGender;

  const AssessmentSummary({
    required this.slug,
    required this.category,
    required this.title,
    required this.shortTitle,
    required this.tagline,
    this.excludedGender,
  });

  bool isVisibleFor(String? userGender) {
    final excluded = excludedGender?.trim().toLowerCase();
    if (excluded == null || excluded.isEmpty) return true;
    final mine = userGender?.trim().toLowerCase();
    // If the member's gender is not available yet, don't expose assessments
    // with a gender exclusion until we can determine whether they apply.
    if (mine == null || mine.isEmpty) return false;
    return excluded != mine;
  }

  @override
  List<Object?> get props => [
    slug,
    category,
    title,
    shortTitle,
    tagline,
    excludedGender,
  ];
}
