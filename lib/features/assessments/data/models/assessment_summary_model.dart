import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';

part 'assessment_summary_model.g.dart';

@JsonSerializable()
class AssessmentSummaryModel {
  final String slug;
  final String category;
  final String title;

  @JsonKey(name: 'short_title')
  final String shortTitle;

  final String tagline;

  @JsonKey(name: 'excluded_gender')
  final String? excludedGender;

  const AssessmentSummaryModel({
    required this.slug,
    required this.category,
    required this.title,
    required this.shortTitle,
    required this.tagline,
    this.excludedGender,
  });

  factory AssessmentSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentSummaryModelToJson(this);

  AssessmentSummary toEntity() => AssessmentSummary(
    slug: slug,
    category: category,
    title: title,
    shortTitle: shortTitle,
    tagline: tagline,
    excludedGender: excludedGender,
  );
}
