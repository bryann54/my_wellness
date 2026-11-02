import 'package:json_annotation/json_annotation.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';

part 'assessment_answer_model.g.dart';

@JsonSerializable()
class AssessmentAnswerModel {
  @JsonKey(name: 'question_key')
  final String questionKey;

  @JsonKey(name: 'question_index')
  final int questionIndex;

  final Object answer;

  @JsonKey(name: 'answered_at')
  final String? answeredAt;

  const AssessmentAnswerModel({
    required this.questionKey,
    required this.questionIndex,
    required this.answer,
    this.answeredAt,
  });

  factory AssessmentAnswerModel.fromJson(Map<String, dynamic> json) =>
      AssessmentAnswerModel(
        questionKey: json['question_key'] as String,
        questionIndex: (json['question_index'] as num).toInt(),
        answer: json['answer'] ?? '',
        answeredAt: json['answered_at'] as String?,
      );

  Map<String, dynamic> toJson() => _$AssessmentAnswerModelToJson(this);

  AssessmentAnswer toEntity() => AssessmentAnswer(
    questionKey: questionKey,
    questionIndex: questionIndex,
    answer: answer,
    answeredAt: answeredAt,
  );
}
