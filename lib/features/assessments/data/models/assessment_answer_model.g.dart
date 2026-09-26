// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentAnswerModel _$AssessmentAnswerModelFromJson(
  Map<String, dynamic> json,
) => AssessmentAnswerModel(
  questionKey: json['question_key'] as String,
  questionIndex: (json['question_index'] as num).toInt(),
  answer: json['answer'] as String,
  answeredAt: json['answered_at'] as String?,
);

Map<String, dynamic> _$AssessmentAnswerModelToJson(
  AssessmentAnswerModel instance,
) => <String, dynamic>{
  'question_key': instance.questionKey,
  'question_index': instance.questionIndex,
  'answer': instance.answer,
  'answered_at': instance.answeredAt,
};
