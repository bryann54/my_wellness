import 'package:equatable/equatable.dart';
import 'assessment_option.dart';

enum AssessmentQuestionType {
  number,
  radio,
  select,
  checkbox,
  bmi,
  text,
  date,
  info,
  unknown,
}

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
  final String? exclusiveValue;
  final bool optional;
  final String? terminateOn;
  final String? skipNextOn;
  final String? skipIf;
  final String? autoAnswerIf;

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
    this.exclusiveValue,
    this.optional = false,
    this.terminateOn,
    this.skipNextOn,
    this.skipIf,
    this.autoAnswerIf,
  });

  static AssessmentQuestionType parseType(String raw) {
    switch (raw.toLowerCase()) {
      case 'number':
        return AssessmentQuestionType.number;
      case 'radio':
        return AssessmentQuestionType.radio;
      case 'select':
        return AssessmentQuestionType.select;
      case 'checkbox':
      case 'multi_select':
      case 'multiselect':
        return AssessmentQuestionType.checkbox;
      case 'bmi':
        return AssessmentQuestionType.bmi;
      case 'text':
        return AssessmentQuestionType.text;
      case 'date':
        return AssessmentQuestionType.date;
      case 'info':
        return AssessmentQuestionType.info;
      default:
        return AssessmentQuestionType.unknown;
    }
  }

  bool get isMultiSelect => type == AssessmentQuestionType.checkbox;

  /// Returns true when [answer] satisfies this question's own rules, mirroring
  /// the server's `is_answer_valid`.
  bool isValidAnswer(String? answer) {
    if (optional && (answer == null || answer.trim().isEmpty)) return true;
    if (answer == null || answer.trim().isEmpty) return false;

    switch (type) {
      case AssessmentQuestionType.radio:
      case AssessmentQuestionType.select:
        return options.any((o) => o.value == answer);
      case AssessmentQuestionType.checkbox:
        final parts = answer.split(',').where((p) => p.isNotEmpty).toList();
        return parts.isNotEmpty &&
            parts.every((p) => options.any((o) => o.value == p));
      case AssessmentQuestionType.number:
        final n = int.tryParse(answer);
        if (n == null) {
          // Could be a fallback option such as "I don't know".
          return options.any((o) => o.value == answer);
        }
        if (min != null && n < min!) return false;
        if (max != null && n > max!) return false;
        return true;
      case AssessmentQuestionType.text:
      case AssessmentQuestionType.date:
        return true;
      case AssessmentQuestionType.bmi:
        return const {
          'underweight',
          'normal',
          'overweight',
          'obese',
        }.contains(answer);
      case AssessmentQuestionType.info:
        return answer == 'acknowledged';
      case AssessmentQuestionType.unknown:
        return true;
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
    exclusiveValue,
    optional,
    terminateOn,
    skipNextOn,
    skipIf,
    autoAnswerIf,
  ];
}
