import 'package:equatable/equatable.dart';

class AssessmentAnswer extends Equatable {
  final String questionKey;
  final int questionIndex;
  final Object answer;

  final String? answeredAt;

  const AssessmentAnswer({
    required this.questionKey,
    required this.questionIndex,
    required this.answer,
    this.answeredAt,
  });

  String get displayValue {
    final a = answer;
    if (a is String) return a;
    if (a is List) return a.join(', ');
    return a.toString();
  }

  @override
  List<Object?> get props => [questionKey, questionIndex, answer, answeredAt];
}
