// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentScoreModel _$AssessmentScoreModelFromJson(
  Map<String, dynamic> json,
) => AssessmentScoreModel(
  hasActiveWarning: json['has_active_warning'] as bool? ?? false,
  offerFacilityShare: json['offer_facility_share'] as bool? ?? false,
  offerCareNavigation: json['offer_care_navigation'] as bool? ?? false,
  resultDisplay: json['result_display'] == null
      ? null
      : ResultDisplayModel.fromJson(
          json['result_display'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AssessmentScoreModelToJson(
  AssessmentScoreModel instance,
) => <String, dynamic>{
  'has_active_warning': instance.hasActiveWarning,
  'offer_facility_share': instance.offerFacilityShare,
  'offer_care_navigation': instance.offerCareNavigation,
  'result_display': instance.resultDisplay?.toJson(),
};

ResultDisplayModel _$ResultDisplayModelFromJson(
  Map<String, dynamic> json,
) => ResultDisplayModel(
  kind: json['kind'] as String?,
  severity: json['severity'] as String?,
  title: json['title'] as String?,
  body: json['body'] as String?,
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
      : CtaSectionModel.fromJson(json['cta_section'] as Map<String, dynamic>),
  actionSummary: json['action_summary'] == null
      ? null
      : ActionSummaryModel.fromJson(
          json['action_summary'] as Map<String, dynamic>,
        ),
  criticalNotice: json['critical_notice'] == null
      ? null
      : NoticeModel.fromJson(json['critical_notice'] as Map<String, dynamic>),
  importantNotice: json['important_notice'] == null
      ? null
      : NoticeModel.fromJson(json['important_notice'] as Map<String, dynamic>),
  cardColor: json['card_color'] == null
      ? null
      : ResultDisplayColorModel.fromJson(
          json['card_color'] as Map<String, dynamic>,
        ),
  colourEmoji: json['colour_emoji'] as String?,
  colourLabel: json['colour_label'] as String?,
  categoryLabel: json['category_label'] as String?,
  recommendationHeading: json['recommendation_heading'] as String?,
  recommendationBody: json['recommendation_body'] as String?,
  observations:
      (json['observations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  primaryCtaLabel: json['primary_cta_label'] as String?,
  secondaryCtaLabel: json['secondary_cta_label'] as String?,
  showReportCard: json['show_report_card'] as bool? ?? false,
  showFooterTiles: json['show_footer_tiles'] as bool? ?? false,
);

Map<String, dynamic> _$ResultDisplayModelToJson(ResultDisplayModel instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'severity': instance.severity,
      'title': instance.title,
      'body': instance.body,
      'metric': instance.metric,
      'nutrition_recommendation': instance.nutritionRecommendation,
      'symptom_alerts_section': instance.symptomAlertsSection,
      'screening_section': instance.screeningSection,
      'cta_section': instance.ctaSection,
      'action_summary': instance.actionSummary,
      'critical_notice': instance.criticalNotice,
      'important_notice': instance.importantNotice,
      'card_color': instance.cardColor,
      'colour_emoji': instance.colourEmoji,
      'colour_label': instance.colourLabel,
      'category_label': instance.categoryLabel,
      'recommendation_heading': instance.recommendationHeading,
      'recommendation_body': instance.recommendationBody,
      'observations': instance.observations,
      'primary_cta_label': instance.primaryCtaLabel,
      'secondary_cta_label': instance.secondaryCtaLabel,
      'show_report_card': instance.showReportCard,
      'show_footer_tiles': instance.showFooterTiles,
    };

ResultDisplayColorModel _$ResultDisplayColorModelFromJson(
  Map<String, dynamic> json,
) => ResultDisplayColorModel(
  accent: json['accent'] as String?,
  soft: json['soft'] as String?,
  border: json['border'] as String?,
  button: json['button'] as String?,
  buttonText: json['button_text'] as String?,
);

Map<String, dynamic> _$ResultDisplayColorModelToJson(
  ResultDisplayColorModel instance,
) => <String, dynamic>{
  'accent': instance.accent,
  'soft': instance.soft,
  'border': instance.border,
  'button': instance.button,
  'button_text': instance.buttonText,
};

ScoreMetricModel _$ScoreMetricModelFromJson(Map<String, dynamic> json) =>
    ScoreMetricModel(
      label: json['label'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$ScoreMetricModelToJson(ScoreMetricModel instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

NutritionRecommendationModel _$NutritionRecommendationModelFromJson(
  Map<String, dynamic> json,
) => NutritionRecommendationModel(
  label: json['label'] as String?,
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
  heading: json['heading'] as String?,
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

SymptomAlertModel _$SymptomAlertModelFromJson(Map<String, dynamic> json) =>
    SymptomAlertModel(
      title: json['title'] as String,
      detail: json['detail'] as String?,
    );

Map<String, dynamic> _$SymptomAlertModelToJson(SymptomAlertModel instance) =>
    <String, dynamic>{'title': instance.title, 'detail': instance.detail};

ScreeningSectionModel _$ScreeningSectionModelFromJson(
  Map<String, dynamic> json,
) => ScreeningSectionModel(
  heading: json['heading'] as String?,
  intro: json['intro'] as String?,
  message: json['message'] as String?,
  bullets:
      (json['bullets'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  ctas:
      (json['ctas'] as List<dynamic>?)
          ?.map((e) => ScreeningCtaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
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

ScreeningCtaModel _$ScreeningCtaModelFromJson(Map<String, dynamic> json) =>
    ScreeningCtaModel(
      key: json['key'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$ScreeningCtaModelToJson(ScreeningCtaModel instance) =>
    <String, dynamic>{'key': instance.key, 'label': instance.label};

CtaSectionModel _$CtaSectionModelFromJson(Map<String, dynamic> json) =>
    CtaSectionModel(
      heading: json['heading'] as String?,
      subheading: json['subheading'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ScreeningCtaModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$CtaSectionModelToJson(CtaSectionModel instance) =>
    <String, dynamic>{
      'heading': instance.heading,
      'subheading': instance.subheading,
      'items': instance.items,
    };

ActionSummaryModel _$ActionSummaryModelFromJson(Map<String, dynamic> json) =>
    ActionSummaryModel(
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      items:
          (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );

Map<String, dynamic> _$ActionSummaryModelToJson(ActionSummaryModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'intro': instance.intro,
      'items': instance.items,
    };

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
  heading: json['heading'] as String?,
  body: json['body'] as String?,
);

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{'heading': instance.heading, 'body': instance.body};
