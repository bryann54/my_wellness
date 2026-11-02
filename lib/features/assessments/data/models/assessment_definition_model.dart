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

  @JsonKey(name: 'before_you_begin')
  final List<BeforeYouBeginPageModel> beforeYouBegin;

  @JsonKey(name: 'cancer_history_type_code')
  final String? cancerHistoryTypeCode;

  @JsonKey(name: 'encouraging_fact')
  final EncouragingFactModel? encouragingFact;

  @JsonKey(name: 'dependant_variant_slug')
  final String? dependantVariantSlug;

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
    this.beforeYouBegin = const [],
    this.cancerHistoryTypeCode,
    this.encouragingFact,
    this.dependantVariantSlug,
  });

  factory AssessmentDefinitionModel.fromJson(Map<String, dynamic> json) {
    final rawByb = json['before_you_begin'];
    final byb = rawByb is List
        ? rawByb
              .whereType<Map<String, dynamic>>()
              .map(BeforeYouBeginPageModel.fromJson)
              .toList(growable: false)
        : <BeforeYouBeginPageModel>[];

    final rawEnc = json['encouraging_fact'];
    final enc = rawEnc is Map<String, dynamic>
        ? EncouragingFactModel.fromJson(rawEnc)
        : null;

    return AssessmentDefinitionModel(
      slug: json['slug'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      shortTitle: json['short_title'] as String,
      tagline: json['tagline'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map(
            (e) => AssessmentQuestionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      ctas: (json['ctas'] as List<dynamic>? ?? const [])
          .map((e) => AssessmentCtaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String?,
      referencePrefix: json['reference_prefix'] as String?,
      understandingCopy: json['understanding_copy'] as String?,
      beforeYouBegin: byb,
      cancerHistoryTypeCode: json['cancer_history_type_code'] as String?,
      encouragingFact: enc,
      dependantVariantSlug: json['dependant_variant_slug'] as String?,
    );
  }

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
    beforeYouBegin: beforeYouBegin
        .map((p) => p.toEntity())
        .toList(growable: false),
    cancerHistoryTypeCode: cancerHistoryTypeCode,
    encouragingFact: encouragingFact?.toEntity(),
    dependantVariantSlug: dependantVariantSlug,
    questions: questions.map((q) => q.toEntity()).toList(growable: false),
    ctas: ctas.map((c) => c.toEntity()).toList(growable: false),
  );
}

@JsonSerializable()
class BeforeYouBeginPageModel {
  final String heading;
  final String body;
  const BeforeYouBeginPageModel({required this.heading, required this.body});

  factory BeforeYouBeginPageModel.fromJson(Map<String, dynamic> json) =>
      _$BeforeYouBeginPageModelFromJson(json);

  Map<String, dynamic> toJson() => _$BeforeYouBeginPageModelToJson(this);

  BeforeYouBeginPage toEntity() =>
      BeforeYouBeginPage(heading: heading, body: body);
}

@JsonSerializable()
class EncouragingFactModel {
  final String emoji;
  final String text;
  const EncouragingFactModel({required this.emoji, required this.text});

  factory EncouragingFactModel.fromJson(Map<String, dynamic> json) =>
      _$EncouragingFactModelFromJson(json);

  Map<String, dynamic> toJson() => _$EncouragingFactModelToJson(this);

  EncouragingFact toEntity() => EncouragingFact(emoji: emoji, text: text);
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

  @JsonKey(name: 'terminate_on')
  final Object? terminateOn;

  @JsonKey(name: 'skip_next_on')
  final Object? skipNextOn;

  @JsonKey(name: 'skip_if')
  final Map<String, dynamic>? skipIf;

  @JsonKey(name: 'auto_answer_if')
  final Map<String, dynamic>? autoAnswerIf;

  @JsonKey(name: 'exclusive_value')
  final String? exclusiveValue;

  final bool optional;

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
    this.terminateOn,
    this.skipNextOn,
    this.skipIf,
    this.autoAnswerIf,
    this.exclusiveValue,
    this.optional = false,
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
    terminateOn: _terminateOnValue(),
    skipNextOn: skipNextOn?.toString(),
    skipIf: skipIf,
    autoAnswerIf: autoAnswerIf,
    exclusiveValue: exclusiveValue,
    optional: optional,
  );

  String? _terminateOnValue() {
    final t = terminateOn;
    if (t == null) return null;
    if (t is String) return t;
    return null;
  }
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
