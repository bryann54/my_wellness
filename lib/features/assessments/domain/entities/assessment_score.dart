import 'package:equatable/equatable.dart';

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
  final String? heading;
  final String? intro;
  final String? outro;
  final List<SymptomAlert> alerts;
  const SymptomAlertsSection({
    this.heading,
    this.intro,
    this.outro,
    this.alerts = const [],
  });

  @override
  List<Object?> get props => [heading, intro, outro, alerts];
}

class ScreeningRecommendation extends Equatable {
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
  const ScreeningRecommendation({
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

class ScreeningCta extends Equatable {
  final String key;
  final String label;
  const ScreeningCta({required this.key, required this.label});

  @override
  List<Object?> get props => [key, label];
}

class CtaSection extends Equatable {
  final String? heading;
  final String? subheading;
  final List<ScreeningCta> items;
  const CtaSection({this.heading, this.subheading, this.items = const []});

  @override
  List<Object?> get props => [heading, subheading, items];
}

class NutritionRecommendation extends Equatable {
  final String? label;
  final String? description;
  const NutritionRecommendation({this.label, this.description});

  @override
  List<Object?> get props => [label, description];
}

class ActionSummary extends Equatable {
  final String? title;
  final String? intro;
  final List<String> items;
  const ActionSummary({this.title, this.intro, this.items = const []});

  @override
  List<Object?> get props => [title, intro, items];
}

class Notice extends Equatable {
  final String? heading;
  final String? body;
  const Notice({this.heading, this.body});

  @override
  List<Object?> get props => [heading, body];
}

// assessment_score.dart
class ResultDisplayColor extends Equatable {
  final String accent;
  final String soft;
  final String border;
  final String button;
  final String buttonText;

  const ResultDisplayColor({
    required this.accent,
    required this.soft,
    required this.border,
    required this.button,
    required this.buttonText,
  });

  @override
  List<Object?> get props => [accent, soft, border, button, buttonText];
}

class ResultDisplay extends Equatable {
  final String? kind;
  final String? severity;
  final String? title;
  final String? body;
  final ScoreMetric? metric;
  final NutritionRecommendation? nutritionRecommendation;
  final SymptomAlertsSection? symptomAlertsSection;
  final ScreeningRecommendation? screeningSection;
  final CtaSection? ctaSection;
  final ActionSummary? actionSummary;
  final Notice? criticalNotice;
  final Notice? importantNotice;
  final ResultDisplayColor? color;
  final String? colourEmoji;
  final String? colourLabel;
  final String? categoryLabel;
  final String? recommendationHeading;
  final String? recommendationBody;
  final List<String> observations;
  final String? primaryCtaLabel;
  final String? secondaryCtaLabel;
  final bool showReportCard;
  final bool showFooterTiles;

  const ResultDisplay({
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
    this.color,
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

  @override
  List<Object?> get props => [
    kind,
    severity,
    title,
    body,
    metric,
    nutritionRecommendation,
    symptomAlertsSection,
    screeningSection,
    ctaSection,
    actionSummary,
    criticalNotice,
    importantNotice,
    color,
    colourEmoji,
    colourLabel,
    categoryLabel,
    recommendationHeading,
    recommendationBody,
    observations,
    primaryCtaLabel,
    secondaryCtaLabel,
    showReportCard,
    showFooterTiles,
  ];
}

class AssessmentScore extends Equatable {
  final bool hasActiveWarning;
  final bool offerFacilityShare;
  final bool offerCareNavigation;
  final ResultDisplay? resultDisplay;

  const AssessmentScore({
    this.hasActiveWarning = false,
    this.offerFacilityShare = false,
    this.offerCareNavigation = false,
    this.resultDisplay,
  });

  String get severity => resultDisplay?.severity ?? 'neutral';
  bool get isTiered => resultDisplay?.kind == 'tiered';
  bool get isGeneric => resultDisplay?.kind == 'generic';
  bool get isStiUti => resultDisplay?.kind == 'sti_uti';
  bool get isEndometriosis => resultDisplay?.kind == 'endometriosis';

  String get title => resultDisplay?.title ?? '';
  String? get body => resultDisplay?.body;

  @override
  List<Object?> get props => [
    hasActiveWarning,
    offerFacilityShare,
    offerCareNavigation,
    resultDisplay,
  ];
}
