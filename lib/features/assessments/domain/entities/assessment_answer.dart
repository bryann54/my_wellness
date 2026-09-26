import 'package:equatable/equatable.dart';

class AssessmentAnswer extends Equatable {
  final String questionKey;
  final int questionIndex;
  final String answer;
  final String? answeredAt;

  const AssessmentAnswer({
    required this.questionKey,
    required this.questionIndex,
    required this.answer,
    this.answeredAt,
  });

  @override
  List<Object?> get props => [questionKey, questionIndex, answer, answeredAt];
}
