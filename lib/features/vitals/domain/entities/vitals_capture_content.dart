import 'package:equatable/equatable.dart';

class VitalsOnboardingIntro extends Equatable {
  final String title;
  final String heading;
  final List<String> paragraphs;

  const VitalsOnboardingIntro({
    required this.title,
    required this.heading,
    required this.paragraphs,
  });

  @override
  List<Object?> get props => [title, heading, paragraphs];
}

class VitalsOnboardingTips extends Equatable {
  final String title;
  final String intro;
  final List<String> items;

  const VitalsOnboardingTips({
    required this.title,
    required this.intro,
    required this.items,
  });

  @override
  List<Object?> get props => [title, intro, items];
}

class VitalsOnboarding extends Equatable {
  final VitalsOnboardingIntro intro;
  final VitalsOnboardingTips tips;

  const VitalsOnboarding({required this.intro, required this.tips});

  @override
  List<Object?> get props => [intro, tips];
}

class VitalsPathwayOption extends Equatable {
  final String value;
  final String label;
  final String? advice;

  const VitalsPathwayOption({
    required this.value,
    required this.label,
    this.advice,
  });

  @override
  List<Object?> get props => [value, label, advice];
}

class VitalsMedicationStep extends Equatable {
  final String label;
  final String helper;

  const VitalsMedicationStep({required this.label, required this.helper});

  @override
  List<Object?> get props => [label, helper];
}

class VitalsPathway extends Equatable {
  final String pathwayQuestion;
  final List<VitalsPathwayOption> pathwayOptions;

  final String? providerPlanQuestion;
  final List<VitalsPathwayOption> providerPlanOptions;

  final String? treatmentGapQuestion;
  final String? treatmentGapHint;
  final List<VitalsPathwayOption> treatmentGapOptions;
  final String? treatmentGapOtherHint;

  final VitalsMedicationStep? medicationStep;

  final String? dialysisDaysQuestion;
  final String? dialysisDaysHint;
  final List<VitalsPathwayOption> dayOptions;

  const VitalsPathway({
    required this.pathwayQuestion,
    required this.pathwayOptions,
    this.providerPlanQuestion,
    this.providerPlanOptions = const [],
    this.treatmentGapQuestion,
    this.treatmentGapHint,
    this.treatmentGapOptions = const [],
    this.treatmentGapOtherHint,
    this.medicationStep,
    this.dialysisDaysQuestion,
    this.dialysisDaysHint,
    this.dayOptions = const [],
  });

  @override
  List<Object?> get props => [
    pathwayQuestion,
    pathwayOptions,
    providerPlanQuestion,
    providerPlanOptions,
    treatmentGapQuestion,
    treatmentGapHint,
    treatmentGapOptions,
    treatmentGapOtherHint,
    medicationStep,
    dialysisDaysQuestion,
    dialysisDaysHint,
    dayOptions,
  ];
}

class VitalsCaptureContent extends Equatable {
  final VitalsOnboarding onboarding;
  final VitalsPathway pathway;

  const VitalsCaptureContent({required this.onboarding, required this.pathway});

  @override
  List<Object?> get props => [onboarding, pathway];
}
