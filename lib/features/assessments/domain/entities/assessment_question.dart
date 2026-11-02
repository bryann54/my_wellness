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
  final String? terminateOn;
  final String? skipNextOn;
  final Map<String, dynamic>? skipIf;
  final Map<String, dynamic>? autoAnswerIf;

  final String? exclusiveValue;

  final bool optional;

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
    this.terminateOn,
    this.skipNextOn,
    this.skipIf,
    this.autoAnswerIf,
    this.exclusiveValue,
    this.optional = false,
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
      case 'multiselect':
      case 'checkbox':
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
    terminateOn,
    skipNextOn,
    skipIf,
    autoAnswerIf,
    exclusiveValue,
    optional,
  ];
}
