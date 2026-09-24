// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentScoreModel _$AssessmentScoreModelFromJson(
  Map<String, dynamic> json,
) => AssessmentScoreModel(
  band: json['band'] as String,
  bandLabel: json['band_label'] as String,
  rawScore: (json['raw_score'] as num).toInt(),
  bandBlurb: json['band_blurb'] as String?,
  metric: json['metric'] == null
      ? null
      : ScoreMetricModel.fromJson(json['metric'] as Map<String, dynamic>),
  contributing:
      (json['contributing'] as List<dynamic>?)
          ?.map((e) => ScoreItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  protective:
      (json['protective'] as List<dynamic>?)
          ?.map((e) => ScoreItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map(
            (e) => ScoreRecommendationModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  hasActiveWarning: json['has_active_warning'] as bool? ?? false,
  computedAt: json['computed_at'] as String?,
  symptomAlerts:
      (json['symptom_alerts'] as List<dynamic>?)
          ?.map((e) => SymptomAlertModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  screeningRecommendation: json['screening_recommendation'] == null
      ? null
      : ScreeningRecommendationModel.fromJson(
          json['screening_recommendation'] as Map<String, dynamic>,
        ),
  additionalCtaKeys:
      (json['additional_cta_keys'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  needsNutritionConsultation:
      json['needs_nutrition_consultation'] as bool? ?? false,
);

Map<String, dynamic> _$AssessmentScoreModelToJson(
  AssessmentScoreModel instance,
) => <String, dynamic>{
  'band': instance.band,
  'band_label': instance.bandLabel,
  'band_blurb': instance.bandBlurb,
  'raw_score': instance.rawScore,
  'metric': instance.metric?.toJson(),
  'contributing': instance.contributing.map((e) => e.toJson()).toList(),
  'protective': instance.protective.map((e) => e.toJson()).toList(),
  'recommendations': instance.recommendations.map((e) => e.toJson()).toList(),
  'has_active_warning': instance.hasActiveWarning,
  'computed_at': instance.computedAt,
  'symptom_alerts': instance.symptomAlerts.map((e) => e.toJson()).toList(),
  'screening_recommendation': instance.screeningRecommendation?.toJson(),
  'additional_cta_keys': instance.additionalCtaKeys,
  'needs_nutrition_consultation': instance.needsNutritionConsultation,
};

ScoreItemModel _$ScoreItemModelFromJson(Map<String, dynamic> json) =>
    ScoreItemModel(
      label: json['label'] as String,
      detail: json['detail'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ScoreItemModelToJson(ScoreItemModel instance) =>
    <String, dynamic>{
      'label': instance.label,
      'detail': instance.detail,
      'weight': instance.weight,
    };

ScoreRecommendationModel _$ScoreRecommendationModelFromJson(
  Map<String, dynamic> json,
) => ScoreRecommendationModel(
  title: json['title'] as String,
  detail: json['detail'] as String?,
);

Map<String, dynamic> _$ScoreRecommendationModelToJson(
  ScoreRecommendationModel instance,
) => <String, dynamic>{'title': instance.title, 'detail': instance.detail};

ScoreMetricModel _$ScoreMetricModelFromJson(Map<String, dynamic> json) =>
    ScoreMetricModel(
      label: json['label'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$ScoreMetricModelToJson(ScoreMetricModel instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

SymptomAlertModel _$SymptomAlertModelFromJson(Map<String, dynamic> json) =>
    SymptomAlertModel(
      title: json['title'] as String,
      detail: json['detail'] as String?,
    );

Map<String, dynamic> _$SymptomAlertModelToJson(SymptomAlertModel instance) =>
    <String, dynamic>{'title': instance.title, 'detail': instance.detail};

ScreeningRecommendationModel _$ScreeningRecommendationModelFromJson(
  Map<String, dynamic> json,
) => ScreeningRecommendationModel(
  status: json['status'] as String,
  title: json['title'] as String,
  message: json['message'] as String?,
  bullets:
      (json['bullets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  ctaKeys:
      (json['cta_keys'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ScreeningRecommendationModelToJson(
  ScreeningRecommendationModel instance,
) => <String, dynamic>{
  'status': instance.status,
  'title': instance.title,
  'message': instance.message,
  'bullets': instance.bullets,
  'cta_keys': instance.ctaKeys,
};
