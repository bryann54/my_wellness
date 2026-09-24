import 'package:equatable/equatable.dart';
import 'assessment_option.dart';

enum AssessmentQuestionType { number, radio, bmi, text, multiSelect, unknown }

class AssessmentQuestion extends Equatable {
  final String key;
  final int index;
  final String section;
  final String prompt;
  final AssessmentQuestionType type;
  final List<AssessmentOption> options;
  final String? insight;
  final String? description;
  final int? min;
  final int? max;

  const AssessmentQuestion({
    required this.key,
    required this.index,
    required this.section,
    required this.prompt,
    required this.type,
    this.options = const [],
    this.insight,
    this.description,
    this.min,
    this.max,
  });

  static AssessmentQuestionType parseType(String raw) {
    switch (raw.toLowerCase()) {
      case 'number':
        return AssessmentQuestionType.number;
      case 'radio':
        return AssessmentQuestionType.radio;
      case 'bmi':
        return AssessmentQuestionType.bmi;
      case 'text':
        return AssessmentQuestionType.text;
      case 'multi_select':
      case 'multiSelect':
        return AssessmentQuestionType.multiSelect;
      default:
        return AssessmentQuestionType.unknown;
    }
  }

  @override
  List<Object?> get props => [
    key,
    index,
    section,
    prompt,
    type,
    options,
    insight,
    description,
    min,
    max,
  ];
}
