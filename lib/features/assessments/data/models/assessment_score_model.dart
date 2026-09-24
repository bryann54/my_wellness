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
  final int rawScore;

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

  const AssessmentScoreModel({
    required this.band,
    required this.bandLabel,
    required this.rawScore,
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
  });

  factory AssessmentScoreModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentScoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentScoreModelToJson(this);

  AssessmentScore toEntity() => AssessmentScore(
    band: band,
    bandLabel: bandLabel,
    bandBlurb: bandBlurb,
    rawScore: rawScore,
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
