import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';

part 'assessment_score_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AssessmentScoreModel {
  final String band;

  @JsonKey(name: 'band_label')
  final String bandLabel;

  @JsonKey(name: 'band_blurb')
  final String? bandBlurb;

  @JsonKey(name: 'raw_score')
  final int? rawScore;

  final ScoreMetricModel? metric;
  final List<ScoreItemModel> contributing;
  final List<ScoreItemModel> protective;
  final List<ScoreRecommendationModel> recommendations;

  @JsonKey(name: 'has_active_warning')
  final bool hasActiveWarning;

  @JsonKey(name: 'computed_at')
  final String? computedAt;

  @JsonKey(name: 'symptom_alerts')
  final List<SymptomAlertModel> symptomAlerts;

  @JsonKey(name: 'screening_recommendation')
  final ScreeningRecommendationModel? screeningRecommendation;

  @JsonKey(name: 'additional_cta_keys')
  final List<String> additionalCtaKeys;

  @JsonKey(name: 'needs_nutrition_consultation')
  final bool needsNutritionConsultation;

  @JsonKey(name: 'result_display')
  final ResultDisplayModel? resultDisplay;

  const AssessmentScoreModel({
    required this.band,
    required this.bandLabel,
    this.rawScore,
    this.bandBlurb,
    this.metric,
    this.contributing = const [],
    this.protective = const [],
    this.recommendations = const [],
    this.hasActiveWarning = false,
    this.computedAt,
    this.symptomAlerts = const [],
    this.screeningRecommendation,
    this.additionalCtaKeys = const [],
    this.needsNutritionConsultation = false,
    this.resultDisplay,
  });

  factory AssessmentScoreModel.fromJson(Map<String, dynamic> json) {
    final display = json['result_display'] as Map<String, dynamic>?;

    // Fallback alerts: prefer top-level, else pull from
    // result_display.symptom_alerts_section.alerts.
    final topAlerts = (json['symptom_alerts'] as List<dynamic>?) ?? const [];
    final displayAlerts =
        (display?['symptom_alerts_section']?['alerts'] as List<dynamic>?) ??
        const [];
    final rawAlerts = topAlerts.isNotEmpty ? topAlerts : displayAlerts;

    return AssessmentScoreModel(
      band:
          (json['band'] as String?) ??
          (display?['severity'] as String?) ??
          'unknown',
      bandLabel:
          (json['band_label'] as String?) ??
          (display?['title'] as String?) ??
          '',
      bandBlurb:
          (json['band_blurb'] as String?) ?? (display?['body'] as String?),
      rawScore: (json['raw_score'] as num?)?.toInt(),
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
                (e) => ScoreRecommendationModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      hasActiveWarning: json['has_active_warning'] as bool? ?? false,
      computedAt: json['computed_at'] as String?,
      symptomAlerts: rawAlerts
          .whereType<Map<String, dynamic>>()
          .map(SymptomAlertModel.fromJson)
          .toList(growable: false),
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
      resultDisplay: display == null
          ? null
          : ResultDisplayModel.fromJson(display),
    );
  }

  Map<String, dynamic> toJson() => _$AssessmentScoreModelToJson(this);

  AssessmentScore toEntity() => AssessmentScore(
    band: band,
    bandLabel: bandLabel,
    bandBlurb: bandBlurb,
    rawScore: rawScore ?? 0,
    metric: metric?.toEntity(),
    contributing: contributing.map((c) => c.toEntity()).toList(growable: false),
    protective: protective.map((p) => p.toEntity()).toList(growable: false),
    recommendations: recommendations
        .map((r) => r.toEntity())
        .toList(growable: false),
    hasActiveWarning: hasActiveWarning,
    computedAt: computedAt,
    symptomAlerts: symptomAlerts
        .map((s) => s.toEntity())
        .toList(growable: false),
    screeningRecommendation: screeningRecommendation?.toEntity(),
    additionalCtaKeys: additionalCtaKeys,
    needsNutritionConsultation: needsNutritionConsultation,
    resultDisplay: resultDisplay?.toEntity(),
  );
}

///result display
@JsonSerializable(explicitToJson: true)
class ResultDisplayModel {
  final String? kind;
  final String? severity;
  final String? title;
  final String? body;

  @JsonKey(name: 'color')
  final Map<String, dynamic>? colorMap;

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
  final NoticeBlockModel? criticalNotice;

  @JsonKey(name: 'important_notice')
  final NoticeBlockModel? importantNotice;

  @JsonKey(name: 'colour_emoji')
  final String? colourEmoji;

  @JsonKey(name: 'colour_label')
  final String? colourLabel;

  @JsonKey(name: 'immediate_recommendation')
  final String? immediateRecommendation;

  @JsonKey(name: 'important_note')
  final String? importantNote;

  @JsonKey(name: 'category_label')
  final String? categoryLabel;

  @JsonKey(name: 'recommendation_heading')
  final String? recommendationHeading;

  @JsonKey(name: 'recommendation_body')
  final String? recommendationBody;

  final List<String> observations;

  @JsonKey(name: 'primary_cta_label')
  final String? primaryCtaLabel;

  @JsonKey(name: 'secondary_cta_label')
  final String? secondaryCtaLabel;

  @JsonKey(name: 'card_color')
  final String? cardColor;

  @JsonKey(name: 'show_report_card')
  final bool showReportCard;

  @JsonKey(name: 'show_footer_tiles')
  final bool showFooterTiles;

  const ResultDisplayModel({
    this.kind,
    this.severity,
    this.title,
    this.body,
    this.colorMap,
    this.metric,
    this.nutritionRecommendation,
    this.symptomAlertsSection,
    this.screeningSection,
    this.ctaSection,
    this.actionSummary,
    this.criticalNotice,
    this.importantNotice,
    this.colourEmoji,
    this.colourLabel,
    this.immediateRecommendation,
    this.importantNote,
    this.categoryLabel,
    this.recommendationHeading,
    this.recommendationBody,
    this.observations = const [],
    this.primaryCtaLabel,
    this.secondaryCtaLabel,
    this.cardColor,
    this.showReportCard = false,
    this.showFooterTiles = false,
  });

  factory ResultDisplayModel.fromJson(Map<String, dynamic> json) {
    final rawObs = json['observations'];
    final obs = rawObs is List
        ? rawObs.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    T? as<T>(String key, T Function(Map<String, dynamic>) build) {
      final v = json[key];
      return v is Map<String, dynamic> ? build(v) : null;
    }

    return ResultDisplayModel(
      kind: json['kind'] as String?,
      severity: json['severity'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      colorMap: json['color'] as Map<String, dynamic>?,
      metric: as('metric', ScoreMetricModel.fromJson),
      nutritionRecommendation: as(
        'nutrition_recommendation',
        NutritionRecommendationModel.fromJson,
      ),
      symptomAlertsSection: as(
        'symptom_alerts_section',
        SymptomAlertsSectionModel.fromJson,
      ),
      screeningSection: as('screening_section', ScreeningSectionModel.fromJson),
      ctaSection: as('cta_section', CtaSectionModel.fromJson),
      actionSummary: as('action_summary', ActionSummaryModel.fromJson),
      criticalNotice: as('critical_notice', NoticeBlockModel.fromJson),
      importantNotice: as('important_notice', NoticeBlockModel.fromJson),
      colourEmoji: json['colour_emoji'] as String?,
      colourLabel: json['colour_label'] as String?,
      immediateRecommendation: json['immediate_recommendation'] as String?,
      importantNote: json['important_note'] as String?,
      categoryLabel: json['category_label'] as String?,
      recommendationHeading: json['recommendation_heading'] as String?,
      recommendationBody: json['recommendation_body'] as String?,
      observations: obs,
      primaryCtaLabel: json['primary_cta_label'] as String?,
      secondaryCtaLabel: json['secondary_cta_label'] as String?,
      cardColor: json['card_color'] as String?,
      showReportCard: json['show_report_card'] as bool? ?? false,
      showFooterTiles: json['show_footer_tiles'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$ResultDisplayModelToJson(this);

  ResultDisplay toEntity() => ResultDisplay(
    kind: kind,
    severity: severity,
    title: title,
    body: body,
    color: colorMap == null
        ? null
        : ResultDisplayColor(
            accent: colorMap!['accent'] as String? ?? '#6B7280',
            background: colorMap!['background'] as String? ?? '#F9FAFB',
            text: colorMap!['text'] as String? ?? '#111827',
          ),
    metric: metric?.toEntity(),
    nutritionRecommendation: nutritionRecommendation?.toEntity(),
    symptomAlertsSection: symptomAlertsSection?.toEntity(),
    screeningSection: screeningSection?.toEntity(),
    ctaSection: ctaSection?.toEntity(),
    actionSummary: actionSummary?.toEntity(),
    criticalNotice: criticalNotice?.toEntity(),
    importantNotice: importantNotice?.toEntity(),
    colourEmoji: colourEmoji,
    colourLabel: colourLabel,
    immediateRecommendation: immediateRecommendation,
    importantNote: importantNote,
    categoryLabel: categoryLabel,
    recommendationHeading: recommendationHeading,
    recommendationBody: recommendationBody,
    observations: observations,
    primaryCtaLabel: primaryCtaLabel,
    secondaryCtaLabel: secondaryCtaLabel,
    cardColor: cardColor,
    showReportCard: showReportCard,
    showFooterTiles: showFooterTiles,
  );
}

@JsonSerializable()
class NutritionRecommendationModel {
  final String label;
  final String? description;
  const NutritionRecommendationModel({required this.label, this.description});

  factory NutritionRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionRecommendationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionRecommendationModelToJson(this);

  NutritionRecommendation toEntity() =>
      NutritionRecommendation(label: label, description: description);
}

@JsonSerializable()
class SymptomAlertsSectionModel {
  final String heading;
  final String? intro;
  final String? outro;
  final List<SymptomAlertModel> alerts;

  const SymptomAlertsSectionModel({
    required this.heading,
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
class ScreeningSectionModel {
  final String? heading;
  final String? intro;
  final String? message;
  final List<String> bullets;
  final List<ScreeningCtaModel> ctas;

  @JsonKey(name: 'independence_note')
  final String? independenceNote;

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

  ScreeningSection toEntity() => ScreeningSection(
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
class CtaSectionItemModel {
  final String key;
  final String label;
  const CtaSectionItemModel({required this.key, required this.label});

  factory CtaSectionItemModel.fromJson(Map<String, dynamic> json) =>
      _$CtaSectionItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CtaSectionItemModelToJson(this);

  CtaSectionItem toEntity() => CtaSectionItem(key: key, label: label);
}

@JsonSerializable()
class CtaSectionModel {
  final String? heading;
  final String? subheading;
  final List<CtaSectionItemModel> items;

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
  final String title;
  final List<String> items;
  const ActionSummaryModel({required this.title, this.items = const []});

  factory ActionSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ActionSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActionSummaryModelToJson(this);

  ActionSummary toEntity() =>
      ActionSummary(title: title, items: List<String>.from(items));
}

@JsonSerializable()
class NoticeBlockModel {
  final String heading;
  final String body;
  const NoticeBlockModel({required this.heading, required this.body});

  factory NoticeBlockModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeBlockModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeBlockModelToJson(this);

  NoticeBlock toEntity() => NoticeBlock(heading: heading, body: body);
}

@JsonSerializable()
class ScoreItemModel {
  final String label;
  final String? detail;
  final int? weight;
  const ScoreItemModel({required this.label, this.detail, this.weight});

  factory ScoreItemModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreItemModelToJson(this);

  ScoreItem toEntity() =>
      ScoreItem(label: label, detail: detail, weight: weight);
}

@JsonSerializable()
class ScoreRecommendationModel {
  final String title;
  final String? detail;
  const ScoreRecommendationModel({required this.title, this.detail});

  factory ScoreRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreRecommendationModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScoreRecommendationModelToJson(this);

  ScoreRecommendation toEntity() =>
      ScoreRecommendation(title: title, detail: detail);
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
class ScreeningRecommendationModel {
  final String status;
  final String title;
  final String? message;
  final List<String> bullets;

  @JsonKey(name: 'cta_keys')
  final List<String> ctaKeys;

  const ScreeningRecommendationModel({
    required this.status,
    required this.title,
    this.message,
    this.bullets = const [],
    this.ctaKeys = const [],
  });

  factory ScreeningRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$ScreeningRecommendationModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScreeningRecommendationModelToJson(this);

  ScreeningRecommendation toEntity() => ScreeningRecommendation(
    status: status,
    title: title,
    message: message,
    bullets: bullets,
    ctaKeys: ctaKeys,
  );
}
