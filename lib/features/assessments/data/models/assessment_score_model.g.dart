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
  rawScore: (json['raw_score'] as num?)?.toInt(),
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
  resultDisplay: json['result_display'] == null
      ? null
      : ResultDisplayModel.fromJson(
          json['result_display'] as Map<String, dynamic>,
        ),
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
  'result_display': instance.resultDisplay?.toJson(),
};

ResultDisplayModel _$ResultDisplayModelFromJson(Map<String, dynamic> json) =>
    ResultDisplayModel(
      kind: json['kind'] as String?,
      severity: json['severity'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      colorMap: json['color'] as Map<String, dynamic>?,
      metric: json['metric'] == null
          ? null
          : ScoreMetricModel.fromJson(json['metric'] as Map<String, dynamic>),
      nutritionRecommendation: json['nutrition_recommendation'] == null
          ? null
          : NutritionRecommendationModel.fromJson(
              json['nutrition_recommendation'] as Map<String, dynamic>,
            ),
      symptomAlertsSection: json['symptom_alerts_section'] == null
          ? null
          : SymptomAlertsSectionModel.fromJson(
              json['symptom_alerts_section'] as Map<String, dynamic>,
            ),
      screeningSection: json['screening_section'] == null
          ? null
          : ScreeningSectionModel.fromJson(
              json['screening_section'] as Map<String, dynamic>,
            ),
      ctaSection: json['cta_section'] == null
          ? null
          : CtaSectionModel.fromJson(
              json['cta_section'] as Map<String, dynamic>,
            ),
      actionSummary: json['action_summary'] == null
          ? null
          : ActionSummaryModel.fromJson(
              json['action_summary'] as Map<String, dynamic>,
            ),
      criticalNotice: json['critical_notice'] == null
          ? null
          : NoticeBlockModel.fromJson(
              json['critical_notice'] as Map<String, dynamic>,
            ),
      importantNotice: json['important_notice'] == null
          ? null
          : NoticeBlockModel.fromJson(
              json['important_notice'] as Map<String, dynamic>,
            ),
      colourEmoji: json['colour_emoji'] as String?,
      colourLabel: json['colour_label'] as String?,
      immediateRecommendation: json['immediate_recommendation'] as String?,
      importantNote: json['important_note'] as String?,
      categoryLabel: json['category_label'] as String?,
      recommendationHeading: json['recommendation_heading'] as String?,
      recommendationBody: json['recommendation_body'] as String?,
      observations:
          (json['observations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      primaryCtaLabel: json['primary_cta_label'] as String?,
      secondaryCtaLabel: json['secondary_cta_label'] as String?,
      cardColor: json['card_color'] as String?,
      showReportCard: json['show_report_card'] as bool? ?? false,
      showFooterTiles: json['show_footer_tiles'] as bool? ?? false,
    );

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
