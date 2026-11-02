// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_definition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentDefinitionModel _$AssessmentDefinitionModelFromJson(
  Map<String, dynamic> json,
) => AssessmentDefinitionModel(
  slug: json['slug'] as String,
  category: json['category'] as String,
  title: json['title'] as String,
  shortTitle: json['short_title'] as String,
  tagline: json['tagline'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => AssessmentQuestionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  ctas: (json['ctas'] as List<dynamic>)
      .map((e) => AssessmentCtaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  disclaimer: json['disclaimer'] as String?,
  referencePrefix: json['reference_prefix'] as String?,
  understandingCopy: json['understanding_copy'] as String?,
  beforeYouBegin:
      (json['before_you_begin'] as List<dynamic>?)
          ?.map(
            (e) => BeforeYouBeginPageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  cancerHistoryTypeCode: json['cancer_history_type_code'] as String?,
  encouragingFact: json['encouraging_fact'] == null
      ? null
      : EncouragingFactModel.fromJson(
          json['encouraging_fact'] as Map<String, dynamic>,
        ),
  dependantVariantSlug: json['dependant_variant_slug'] as String?,
);

Map<String, dynamic> _$AssessmentDefinitionModelToJson(
  AssessmentDefinitionModel instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'category': instance.category,
  'title': instance.title,
  'short_title': instance.shortTitle,
  'tagline': instance.tagline,
  'disclaimer': instance.disclaimer,
  'reference_prefix': instance.referencePrefix,
  'understanding_copy': instance.understandingCopy,
  'before_you_begin': instance.beforeYouBegin.map((e) => e.toJson()).toList(),
  'cancer_history_type_code': instance.cancerHistoryTypeCode,
  'encouraging_fact': instance.encouragingFact?.toJson(),
  'dependant_variant_slug': instance.dependantVariantSlug,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
  'ctas': instance.ctas.map((e) => e.toJson()).toList(),
};

BeforeYouBeginPageModel _$BeforeYouBeginPageModelFromJson(
  Map<String, dynamic> json,
) => BeforeYouBeginPageModel(
  heading: json['heading'] as String,
  body: json['body'] as String,
);

Map<String, dynamic> _$BeforeYouBeginPageModelToJson(
  BeforeYouBeginPageModel instance,
) => <String, dynamic>{'heading': instance.heading, 'body': instance.body};

EncouragingFactModel _$EncouragingFactModelFromJson(
  Map<String, dynamic> json,
) => EncouragingFactModel(
  emoji: json['emoji'] as String,
  text: json['text'] as String,
);

Map<String, dynamic> _$EncouragingFactModelToJson(
  EncouragingFactModel instance,
) => <String, dynamic>{'emoji': instance.emoji, 'text': instance.text};

AssessmentQuestionModel _$AssessmentQuestionModelFromJson(
  Map<String, dynamic> json,
) => AssessmentQuestionModel(
  key: json['key'] as String,
  index: (json['index'] as num).toInt(),
  section: json['section'] as String,
  prompt: json['prompt'] as String,
  type: json['type'] as String,
  options:
      (json['options'] as List<dynamic>?)
          ?.map(
            (e) => AssessmentOptionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  insight: json['insight'] as String?,
  description: json['description'] as String?,
  min: (json['min'] as num?)?.toInt(),
  max: (json['max'] as num?)?.toInt(),
  terminateOn: json['terminate_on'],
  skipNextOn: json['skip_next_on'],
  skipIf: json['skip_if'] as Map<String, dynamic>?,
  autoAnswerIf: json['auto_answer_if'] as Map<String, dynamic>?,
  exclusiveValue: json['exclusive_value'] as String?,
  optional: json['optional'] as bool? ?? false,
);

Map<String, dynamic> _$AssessmentQuestionModelToJson(
  AssessmentQuestionModel instance,
) => <String, dynamic>{
  'key': instance.key,
  'index': instance.index,
  'section': instance.section,
  'prompt': instance.prompt,
  'type': instance.type,
  'options': instance.options,
  'insight': instance.insight,
  'description': instance.description,
  'min': instance.min,
  'max': instance.max,
  'terminate_on': instance.terminateOn,
  'skip_next_on': instance.skipNextOn,
  'skip_if': instance.skipIf,
  'auto_answer_if': instance.autoAnswerIf,
  'exclusive_value': instance.exclusiveValue,
  'optional': instance.optional,
};

AssessmentOptionModel _$AssessmentOptionModelFromJson(
  Map<String, dynamic> json,
) => AssessmentOptionModel(
  value: json['value'] as String,
  label: json['label'] as String,
);

Map<String, dynamic> _$AssessmentOptionModelToJson(
  AssessmentOptionModel instance,
) => <String, dynamic>{'value': instance.value, 'label': instance.label};

AssessmentCtaModel _$AssessmentCtaModelFromJson(Map<String, dynamic> json) =>
    AssessmentCtaModel(
      key: json['key'] as String,
      label: json['label'] as String,
      serviceType: json['service_type'] as String?,
      serviceLabel: json['service_label'] as String?,
      description: json['description'] as String?,
      priceKes: (json['price_kes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AssessmentCtaModelToJson(AssessmentCtaModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'service_type': instance.serviceType,
      'service_label': instance.serviceLabel,
      'description': instance.description,
      'price_kes': instance.priceKes,
    };
