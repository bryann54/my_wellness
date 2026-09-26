import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_cta.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_option.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_question.dart';
part 'assessment_definition_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AssessmentDefinitionModel {
  final String slug;
  final String category;
  final String title;

  @JsonKey(name: 'short_title')
  final String shortTitle;

  final String tagline;
  final String? disclaimer;

  @JsonKey(name: 'reference_prefix')
  final String? referencePrefix;

  @JsonKey(name: 'understanding_copy')
  final String? understandingCopy;

  final List<AssessmentQuestionModel> questions;
  final List<AssessmentCtaModel> ctas;

  const AssessmentDefinitionModel({
    required this.slug,
    required this.category,
    required this.title,
    required this.shortTitle,
    required this.tagline,
    required this.questions,
    required this.ctas,
    this.disclaimer,
    this.referencePrefix,
    this.understandingCopy,
  });

  factory AssessmentDefinitionModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentDefinitionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentDefinitionModelToJson(this);

  AssessmentDefinition toEntity() => AssessmentDefinition(
    slug: slug,
    category: category,
    title: title,
    shortTitle: shortTitle,
    tagline: tagline,
    disclaimer: disclaimer,
    referencePrefix: referencePrefix,
    understandingCopy: understandingCopy,
    questions: questions.map((q) => q.toEntity()).toList(growable: false),
    ctas: ctas.map((c) => c.toEntity()).toList(growable: false),
  );
}

@JsonSerializable()
class AssessmentQuestionModel {
  final String key;
  final int index;
  final String section;
  final String prompt;
  final String type;
  final List<AssessmentOptionModel> options;
  final String? insight;
  final String? description;
  final int? min;
  final int? max;

  const AssessmentQuestionModel({
    required this.key,
    required this.index,
    required this.section,
    required this.prompt,
    required this.type,
    this.options = const [],
    this.insight,
    this.description,
    this.min,
    this.max,
  });

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentQuestionModelToJson(this);

  AssessmentQuestion toEntity() => AssessmentQuestion(
    key: key,
    index: index,
    section: section,
    prompt: prompt,
    type: AssessmentQuestion.parseType(type),
    options: options.map((o) => o.toEntity()).toList(growable: false),
    insight: insight,
    description: description,
    min: min,
    max: max,
  );
}

@JsonSerializable()
class AssessmentOptionModel {
  final String value;
  final String label;

  const AssessmentOptionModel({required this.value, required this.label});

  factory AssessmentOptionModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentOptionModelToJson(this);

  AssessmentOption toEntity() => AssessmentOption(value: value, label: label);
}

@JsonSerializable()
class AssessmentCtaModel {
  final String key;
  final String label;

  @JsonKey(name: 'service_type')
  final String? serviceType;

  @JsonKey(name: 'service_label')
  final String? serviceLabel;

  final String? description;

  @JsonKey(name: 'price_kes')
  final int? priceKes;

  const AssessmentCtaModel({
    required this.key,
    required this.label,
    this.serviceType,
    this.serviceLabel,
    this.description,
    this.priceKes,
  });

  factory AssessmentCtaModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentCtaModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentCtaModelToJson(this);

  AssessmentCta toEntity() => AssessmentCta(
    key: key,
    label: label,
    serviceType: serviceType,
    serviceLabel: serviceLabel,
    description: description,
    priceKes: priceKes,
  );
}
