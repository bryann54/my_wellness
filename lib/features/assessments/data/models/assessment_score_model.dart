import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

part 'assessment_score_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AssessmentScoreModel {
  @JsonKey(name: 'has_active_warning')
  final bool hasActiveWarning;

  @JsonKey(name: 'offer_facility_share')
  final bool offerFacilityShare;

  @JsonKey(name: 'offer_care_navigation')
  final bool offerCareNavigation;

  @JsonKey(name: 'result_display')
  final ResultDisplayModel? resultDisplay;

  const AssessmentScoreModel({
    this.hasActiveWarning = false,
    this.offerFacilityShare = false,
    this.offerCareNavigation = false,
    this.resultDisplay,
  });

  factory AssessmentScoreModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentScoreModelToJson(this);

  AssessmentScore toEntity() => AssessmentScore(
    hasActiveWarning: hasActiveWarning,
    offerFacilityShare: offerFacilityShare,
    offerCareNavigation: offerCareNavigation,
    resultDisplay: resultDisplay?.toEntity(),
  );
}

@JsonSerializable()
class ResultDisplayModel {
  final String? kind;
  final String? severity;
  final String? title;
  final String? body;
  final ScoreMetricModel? metric;

  @JsonKey(name: 'nutrition_recommendation')
  final NutritionRecommendationModel? nutritionRecommendation;

  @JsonKey(name: 'symptom_alerts_section')
  final SymptomAlertsSectionModel? symptomAlertsSection;

  @JsonKey(name: 'screening_section')
  final ScreeningSectionModel? screeningSection;

  @JsonKey(name: 'cta_section')
  final CtaSectionModel? ctaSection;

  @JsonKey(name: 'action_summary')
  final ActionSummaryModel? actionSummary;

  @JsonKey(name: 'critical_notice')
  final NoticeModel? criticalNotice;

  @JsonKey(name: 'important_notice')
  final NoticeModel? importantNotice;

  @JsonKey(name: 'card_color')
  final ResultDisplayColorModel? cardColor;

  @JsonKey(name: 'colour_emoji')
  final String? colourEmoji;

  @JsonKey(name: 'colour_label')
  final String? colourLabel;

  @JsonKey(name: 'category_label')
  final String? categoryLabel;

  @JsonKey(name: 'recommendation_heading')
  final String? recommendationHeading;

  @JsonKey(name: 'recommendation_body')
  final String? recommendationBody;

  @JsonKey(defaultValue: [])
  final List<String> observations;

  @JsonKey(name: 'primary_cta_label')
  final String? primaryCtaLabel;

  @JsonKey(name: 'secondary_cta_label')
  final String? secondaryCtaLabel;

  @JsonKey(name: 'show_report_card')
  final bool showReportCard;

  @JsonKey(name: 'show_footer_tiles')
  final bool showFooterTiles;

  const ResultDisplayModel({
    this.kind,
    this.severity,
    this.title,
    this.body,
    this.metric,
    this.nutritionRecommendation,
    this.symptomAlertsSection,
    this.screeningSection,
    this.ctaSection,
    this.actionSummary,
    this.criticalNotice,
    this.importantNotice,
    this.cardColor,
    this.colourEmoji,
    this.colourLabel,
    this.categoryLabel,
    this.recommendationHeading,
    this.recommendationBody,
    this.observations = const [],
    this.primaryCtaLabel,
    this.secondaryCtaLabel,
    this.showReportCard = false,
    this.showFooterTiles = false,
  });

  factory ResultDisplayModel.fromJson(Map<String, dynamic> json) =>
      _$ResultDisplayModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResultDisplayModelToJson(this);

  ResultDisplay toEntity() => ResultDisplay(
    kind: kind,
    severity: severity,
    title: title,
    body: body,
    metric: metric?.toEntity(),
    nutritionRecommendation: nutritionRecommendation?.toEntity(),
    symptomAlertsSection: symptomAlertsSection?.toEntity(),
    screeningSection: screeningSection?.toEntity(),
    ctaSection: ctaSection?.toEntity(),
    actionSummary: actionSummary?.toEntity(),
    criticalNotice: criticalNotice?.toEntity(),
    importantNotice: importantNotice?.toEntity(),
    color: cardColor?.toEntity(),
    colourEmoji: colourEmoji,
    colourLabel: colourLabel,
    categoryLabel: categoryLabel,
    recommendationHeading: recommendationHeading,
    recommendationBody: recommendationBody,
    observations: observations,
    primaryCtaLabel: primaryCtaLabel,
    secondaryCtaLabel: secondaryCtaLabel,
    showReportCard: showReportCard,
    showFooterTiles: showFooterTiles,
  );
}

// assessment_score_model.dart
@JsonSerializable()
class ResultDisplayColorModel {
  final String? accent;
  final String? soft;
  final String? border;
  final String? button;

  @JsonKey(name: 'button_text')
  final String? buttonText;

  const ResultDisplayColorModel({
    this.accent,
    this.soft,
    this.border,
    this.button,
    this.buttonText,
  });

  factory ResultDisplayColorModel.fromJson(Map<String, dynamic> json) =>
      _$ResultDisplayColorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResultDisplayColorModelToJson(this);

  ResultDisplayColor toEntity() {
    final a = accent ?? '#6B7280';
    return ResultDisplayColor(
      accent: a,
      soft: soft ?? '#F9FAFB',
      border: border ?? a,
      button: button ?? a,
      buttonText: buttonText ?? '#FFFFFF',
    );
  }
}

@JsonSerializable()
class ScoreMetricModel {
  final String label;
  final String value;
  const ScoreMetricModel({required this.label, required this.value});

  factory ScoreMetricModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreMetricModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreMetricModelToJson(this);

  ScoreMetric toEntity() => ScoreMetric(label: label, value: value);
}

@JsonSerializable()
class NutritionRecommendationModel {
  final String? label;
  final String? description;
  const NutritionRecommendationModel({this.label, this.description});

  factory NutritionRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionRecommendationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionRecommendationModelToJson(this);

  NutritionRecommendation toEntity() =>
      NutritionRecommendation(label: label, description: description);
}

@JsonSerializable()
class SymptomAlertsSectionModel {
  final String? heading;
  final String? intro;
  final String? outro;
  final List<SymptomAlertModel> alerts;
  const SymptomAlertsSectionModel({
    this.heading,
    this.intro,
    this.outro,
    this.alerts = const [],
  });

  factory SymptomAlertsSectionModel.fromJson(Map<String, dynamic> json) =>
      _$SymptomAlertsSectionModelFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomAlertsSectionModelToJson(this);

  SymptomAlertsSection toEntity() => SymptomAlertsSection(
    heading: heading,
    intro: intro,
    outro: outro,
    alerts: alerts.map((a) => a.toEntity()).toList(growable: false),
  );
}

@JsonSerializable()
class SymptomAlertModel {
  final String title;
  final String? detail;
  const SymptomAlertModel({required this.title, this.detail});

  factory SymptomAlertModel.fromJson(Map<String, dynamic> json) =>
      _$SymptomAlertModelFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomAlertModelToJson(this);

  SymptomAlert toEntity() => SymptomAlert(title: title, detail: detail);
}

@JsonSerializable()
class ScreeningSectionModel {
  final String? heading;
  final String? intro;
  final String? message;
  @JsonKey(defaultValue: [])
  final List<String> bullets;
  @JsonKey(defaultValue: [])
  final List<ScreeningCtaModel> ctas;
  @JsonKey(name: 'independence_note')
  final String? independenceNote;
  @JsonKey(defaultValue: false)
  final bool due;
  @JsonKey(name: 'status_code')
  final String? statusCode;
  final String? interval;
  final String? basis;
  final String? method;
  final String? description;

  const ScreeningSectionModel({
    this.heading,
    this.intro,
    this.message,
    this.bullets = const [],
    this.ctas = const [],
    this.independenceNote,
    this.due = false,
    this.statusCode,
    this.interval,
    this.basis,
    this.method,
    this.description,
  });

  factory ScreeningSectionModel.fromJson(Map<String, dynamic> json) =>
      _$ScreeningSectionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScreeningSectionModelToJson(this);

  ScreeningRecommendation toEntity() => ScreeningRecommendation(
    heading: heading,
    intro: intro,
    message: message,
    bullets: bullets,
    ctas: ctas.map((c) => c.toEntity()).toList(growable: false),
    independenceNote: independenceNote,
    due: due,
    statusCode: statusCode,
    interval: interval,
    basis: basis,
    method: method,
    description: description,
  );
}

@JsonSerializable()
class ScreeningCtaModel {
  final String key;
  final String label;
  const ScreeningCtaModel({required this.key, required this.label});

  factory ScreeningCtaModel.fromJson(Map<String, dynamic> json) =>
      _$ScreeningCtaModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScreeningCtaModelToJson(this);

  ScreeningCta toEntity() => ScreeningCta(key: key, label: label);
}

@JsonSerializable()
class CtaSectionModel {
  final String? heading;
  final String? subheading;
  @JsonKey(defaultValue: [])
  final List<ScreeningCtaModel> items;

  const CtaSectionModel({this.heading, this.subheading, this.items = const []});

  factory CtaSectionModel.fromJson(Map<String, dynamic> json) =>
      _$CtaSectionModelFromJson(json);
  Map<String, dynamic> toJson() => _$CtaSectionModelToJson(this);

  CtaSection toEntity() => CtaSection(
    heading: heading,
    subheading: subheading,
    items: items.map((i) => i.toEntity()).toList(growable: false),
  );
}

@JsonSerializable()
class ActionSummaryModel {
  final String? title;
  final String? intro;
  @JsonKey(defaultValue: [])
  final List<String> items;
  const ActionSummaryModel({this.title, this.intro, this.items = const []});

  factory ActionSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ActionSummaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$ActionSummaryModelToJson(this);

  ActionSummary toEntity() =>
      ActionSummary(title: title, intro: intro, items: items);
}

@JsonSerializable()
class NoticeModel {
  final String? heading;
  final String? body;
  const NoticeModel({this.heading, this.body});

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);

  Notice toEntity() => Notice(heading: heading, body: body);
}
