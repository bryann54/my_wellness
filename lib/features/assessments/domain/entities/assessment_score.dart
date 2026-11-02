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

class SymptomAlertsSection extends Equatable {
  final String heading;
  final String? intro;
  final String? outro;
  final List<SymptomAlert> alerts;
  const SymptomAlertsSection({
    required this.heading,
    this.intro,
    this.outro,
    this.alerts = const [],
  });

  @override
  List<Object?> get props => [heading, intro, outro, alerts];
}

class NutritionRecommendation extends Equatable {
  final String label;
  final String? description;
  const NutritionRecommendation({required this.label, this.description});

  @override
  List<Object?> get props => [label, description];
}

class ScreeningCta extends Equatable {
  final String key;
  final String label;
  const ScreeningCta({required this.key, required this.label});

  @override
  List<Object?> get props => [key, label];
}

class ScreeningSection extends Equatable {
  final String? heading;
  final String? intro;
  final String? message;
  final List<String> bullets;
  final List<ScreeningCta> ctas;
  final String? independenceNote;
  final bool due;
  final String? statusCode;
  final String? interval;
  final String? basis;
  final String? method;
  final String? description;

  const ScreeningSection({
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

  @override
  List<Object?> get props => [
    heading,
    intro,
    message,
    bullets,
    ctas,
    independenceNote,
    due,
    statusCode,
    interval,
    basis,
    method,
    description,
  ];
}

class CtaSectionItem extends Equatable {
  final String key;
  final String label;
  const CtaSectionItem({required this.key, required this.label});

  @override
  List<Object?> get props => [key, label];
}

class CtaSection extends Equatable {
  final String? heading;
  final String? subheading;
  final List<CtaSectionItem> items;
  const CtaSection({this.heading, this.subheading, this.items = const []});

  @override
  List<Object?> get props => [heading, subheading, items];
}

class ActionSummary extends Equatable {
  final String title;
  final List<String> items;
  const ActionSummary({required this.title, this.items = const []});

  @override
  List<Object?> get props => [title, items];
}

class NoticeBlock extends Equatable {
  final String heading;
  final String body;
  const NoticeBlock({required this.heading, required this.body});

  @override
  List<Object?> get props => [heading, body];
}

class ResultDisplayColor extends Equatable {
  final String accent;
  final String background;
  final String text;

  const ResultDisplayColor({
    required this.accent,
    required this.background,
    required this.text,
  });

  @override
  List<Object?> get props => [accent, background, text];
}

class ResultDisplay extends Equatable {
  final String? kind;
  final String? severity;
  final String? title;
  final String? body;
  final ResultDisplayColor? color;

  final ScoreMetric? metric;
  final NutritionRecommendation? nutritionRecommendation;
  final SymptomAlertsSection? symptomAlertsSection;
  final ScreeningSection? screeningSection;
  final CtaSection? ctaSection;

  final ActionSummary? actionSummary;
  final NoticeBlock? criticalNotice;
  final NoticeBlock? importantNotice;

  final String? colourEmoji;
  final String? colourLabel;
  final String? immediateRecommendation;
  final String? importantNote;
  final String? categoryLabel;
  final String? recommendationHeading;
  final String? recommendationBody;
  final List<String> observations;
  final String? primaryCtaLabel;
  final String? secondaryCtaLabel;
  final String? cardColor;
  final bool showReportCard;
  final bool showFooterTiles;

  const ResultDisplay({
    this.kind,
    this.severity,
    this.title,
    this.body,
    this.color,
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

  bool get isCancerTiered => kind == 'tiered' && actionSummary != null;

  @override
  List<Object?> get props => [
    kind,
    severity,
    title,
    body,
    color,
    metric,
    nutritionRecommendation,
    symptomAlertsSection,
    screeningSection,
    ctaSection,
    actionSummary,
    criticalNotice,
    importantNotice,
    colourEmoji,
    colourLabel,
    immediateRecommendation,
    importantNote,
    categoryLabel,
    recommendationHeading,
    recommendationBody,
    observations,
    primaryCtaLabel,
    secondaryCtaLabel,
    cardColor,
    showReportCard,
    showFooterTiles,
  ];
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
  final ResultDisplay? resultDisplay;

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
    this.resultDisplay,
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
    resultDisplay,
  ];
}
