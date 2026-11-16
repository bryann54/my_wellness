import 'package:equatable/equatable.dart';

class AssessmentSummary extends Equatable {
  final String slug;
  final String category;
  final String title;
  final String shortTitle;
  final String tagline;
  final String? excludedGender;
  final String? dependantVariantSlug;

  const AssessmentSummary({
    required this.slug,
    required this.category,
    required this.title,
    required this.shortTitle,
    required this.tagline,
    this.excludedGender,
    this.dependantVariantSlug,
  });

  bool isVisibleFor(String? userGender) {
    final excluded = excludedGender?.trim().toLowerCase();
    if (excluded == null || excluded.isEmpty) return true;
    // Contract: a parent with a dependant variant remains in the catalogue;
    // the server selects the appropriate variant when it is opened.
    if (dependantVariantSlug?.trim().isNotEmpty == true) return true;
    final mine = userGender?.trim().toLowerCase();
    // With no known gender there is no matching exclusion to apply.
    if (mine == null || mine.isEmpty) return true;
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
    dependantVariantSlug,
  ];
}
