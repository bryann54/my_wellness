import 'package:equatable/equatable.dart';

class ScoreItem extends Equatable {
  final String label;
  final String? detail;
  final int? weight;
  const ScoreItem({required this.label, this.detail, this.weight});

  @override
  List<Object?> get props => [label, detail, weight];
}

class ScoreRecommendation extends Equatable {
  final String title;
  final String? detail;
  const ScoreRecommendation({required this.title, this.detail});

  @override
  List<Object?> get props => [title, detail];
}

class ScoreMetric extends Equatable {
  final String label;
  final String value;
  const ScoreMetric({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}

class SymptomAlert extends Equatable {
  final String title;
  final String? detail;
  const SymptomAlert({required this.title, this.detail});

  @override
  List<Object?> get props => [title, detail];
}

class ScreeningRecommendation extends Equatable {
  final String status;
  final String title;
  final String? message;
  final List<String> bullets;
  final List<String> ctaKeys;
  const ScreeningRecommendation({
    required this.status,
    required this.title,
    this.message,
    this.bullets = const [],
    this.ctaKeys = const [],
  });

  @override
  List<Object?> get props => [status, title, message, bullets, ctaKeys];
}

class AssessmentScore extends Equatable {
  final String band;
  final String bandLabel;
  final String? bandBlurb;
  final int rawScore;
  final ScoreMetric? metric;
  final List<ScoreItem> contributing;
  final List<ScoreItem> protective;
  final List<ScoreRecommendation> recommendations;
  final bool hasActiveWarning;
  final String? computedAt;
  final List<SymptomAlert> symptomAlerts;
  final ScreeningRecommendation? screeningRecommendation;
  final List<String> additionalCtaKeys;
  final bool needsNutritionConsultation;

  const AssessmentScore({
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

  @override
  List<Object?> get props => [
    band,
    bandLabel,
    bandBlurb,
    rawScore,
    metric,
    contributing,
    protective,
    recommendations,
    hasActiveWarning,
    computedAt,
    symptomAlerts,
    screeningRecommendation,
    additionalCtaKeys,
    needsNutritionConsultation,
  ];
}
