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
    // Fall back gracefully when the backend sends a `result_display`
    // wrapper instead of the flat band/band_label/band_blurb shape.
    final display = json['result_display'] as Map<String, dynamic>?;

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
      symptomAlerts:
          (json['symptom_alerts'] as List<dynamic>?)
              ?.map(
                (e) => SymptomAlertModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          (display?['symptom_alerts_section']?['alerts'] as List<dynamic>?)
              ?.map(
                (e) => SymptomAlertModel.fromJson(e as Map<String, dynamic>),
              )
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
  );
}

@JsonSerializable()
class ResultDisplayModel {
  final String? kind;
  final String? severity;
  final String? title;
  final String? body;

  @JsonKey(name: 'severity_color')
  final Map<String, dynamic>? severityColor;

  const ResultDisplayModel({
    this.kind,
    this.severity,
    this.title,
    this.body,
    this.severityColor,
  });

  factory ResultDisplayModel.fromJson(Map<String, dynamic> json) =>
      ResultDisplayModel(
        kind: json['kind'] as String?,
        severity: json['severity'] as String?,
        title: json['title'] as String?,
        body: json['body'] as String?,
        severityColor: json['color'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'severity': severity,
    'title': title,
    'body': body,
    'color': severityColor,
  };
}

// ── Existing inner models (unchanged) ────────────────────────────────────────

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
