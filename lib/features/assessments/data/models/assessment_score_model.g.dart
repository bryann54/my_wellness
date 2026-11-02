// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************


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
  'result_display': instance.resultDisplay?.toJson(),
};


Map<String, dynamic> _$ResultDisplayModelToJson(ResultDisplayModel instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'severity': instance.severity,
      'title': instance.title,
      'body': instance.body,
      'color': instance.colorMap,
      'metric': instance.metric?.toJson(),
      'nutrition_recommendation': instance.nutritionRecommendation?.toJson(),
      'symptom_alerts_section': instance.symptomAlertsSection?.toJson(),
      'screening_section': instance.screeningSection?.toJson(),
      'cta_section': instance.ctaSection?.toJson(),
      'action_summary': instance.actionSummary?.toJson(),
      'critical_notice': instance.criticalNotice?.toJson(),
      'important_notice': instance.importantNotice?.toJson(),
      'colour_emoji': instance.colourEmoji,
      'colour_label': instance.colourLabel,
      'immediate_recommendation': instance.immediateRecommendation,
      'important_note': instance.importantNote,
      'category_label': instance.categoryLabel,
      'recommendation_heading': instance.recommendationHeading,
      'recommendation_body': instance.recommendationBody,
      'observations': instance.observations,
      'primary_cta_label': instance.primaryCtaLabel,
      'secondary_cta_label': instance.secondaryCtaLabel,
      'card_color': instance.cardColor,
      'show_report_card': instance.showReportCard,
      'show_footer_tiles': instance.showFooterTiles,
    };

NutritionRecommendationModel _$NutritionRecommendationModelFromJson(
  Map<String, dynamic> json,
) => NutritionRecommendationModel(
  label: json['label'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$NutritionRecommendationModelToJson(
  NutritionRecommendationModel instance,
) => <String, dynamic>{
  'label': instance.label,
  'description': instance.description,
};

SymptomAlertsSectionModel _$SymptomAlertsSectionModelFromJson(
  Map<String, dynamic> json,
) => SymptomAlertsSectionModel(
  heading: json['heading'] as String,
  intro: json['intro'] as String?,
  outro: json['outro'] as String?,
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => SymptomAlertModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SymptomAlertsSectionModelToJson(
  SymptomAlertsSectionModel instance,
) => <String, dynamic>{
  'heading': instance.heading,
  'intro': instance.intro,
  'outro': instance.outro,
  'alerts': instance.alerts,
};

ScreeningCtaModel _$ScreeningCtaModelFromJson(Map<String, dynamic> json) =>
    ScreeningCtaModel(
      key: json['key'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$ScreeningCtaModelToJson(ScreeningCtaModel instance) =>
    <String, dynamic>{'key': instance.key, 'label': instance.label};

ScreeningSectionModel _$ScreeningSectionModelFromJson(
  Map<String, dynamic> json,
) => ScreeningSectionModel(
  heading: json['heading'] as String?,
  intro: json['intro'] as String?,
  message: json['message'] as String?,
  bullets:
      (json['bullets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  ctas:
      (json['ctas'] as List<dynamic>?)
          ?.map((e) => ScreeningCtaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  independenceNote: json['independence_note'] as String?,
  due: json['due'] as bool? ?? false,
  statusCode: json['status_code'] as String?,
  interval: json['interval'] as String?,
  basis: json['basis'] as String?,
  method: json['method'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ScreeningSectionModelToJson(
  ScreeningSectionModel instance,
) => <String, dynamic>{
  'heading': instance.heading,
  'intro': instance.intro,
  'message': instance.message,
  'bullets': instance.bullets,
  'ctas': instance.ctas,
  'independence_note': instance.independenceNote,
  'due': instance.due,
  'status_code': instance.statusCode,
  'interval': instance.interval,
  'basis': instance.basis,
  'method': instance.method,
  'description': instance.description,
};

CtaSectionItemModel _$CtaSectionItemModelFromJson(Map<String, dynamic> json) =>
    CtaSectionItemModel(
      key: json['key'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$CtaSectionItemModelToJson(
  CtaSectionItemModel instance,
) => <String, dynamic>{'key': instance.key, 'label': instance.label};

CtaSectionModel _$CtaSectionModelFromJson(Map<String, dynamic> json) =>
    CtaSectionModel(
      heading: json['heading'] as String?,
      subheading: json['subheading'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => CtaSectionItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CtaSectionModelToJson(CtaSectionModel instance) =>
    <String, dynamic>{
      'heading': instance.heading,
      'subheading': instance.subheading,
      'items': instance.items,
    };

ActionSummaryModel _$ActionSummaryModelFromJson(Map<String, dynamic> json) =>
    ActionSummaryModel(
      title: json['title'] as String,
      items:
          (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$ActionSummaryModelToJson(ActionSummaryModel instance) =>
    <String, dynamic>{'title': instance.title, 'items': instance.items};

NoticeBlockModel _$NoticeBlockModelFromJson(Map<String, dynamic> json) =>
    NoticeBlockModel(
      heading: json['heading'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$NoticeBlockModelToJson(NoticeBlockModel instance) =>
    <String, dynamic>{'heading': instance.heading, 'body': instance.body};

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
