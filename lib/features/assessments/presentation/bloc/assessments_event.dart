part of 'assessments_bloc.dart';

abstract class AssessmentsEvent extends Equatable {
  const AssessmentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssessmentsEvent extends AssessmentsEvent {
  final String? userGender;
  const LoadAssessmentsEvent({this.userGender});
  @override
  List<Object?> get props => [userGender];
}

class StartAssessmentsEvent extends AssessmentsEvent {
  final String slug;
  const StartAssessmentsEvent(this.slug);
  @override
  List<Object?> get props => [slug];
}

class ResumeAssessmentsEvent extends AssessmentsEvent {
  final String slug;
  final String sessionId;
  const ResumeAssessmentsEvent({required this.slug, required this.sessionId});
  @override
  List<Object?> get props => [slug, sessionId];
}

class SubmitAnswerEvent extends AssessmentsEvent {
  final String questionKey;
  final int questionIndex;
  final String answer;
  const SubmitAnswerEvent({
    required this.questionKey,
    required this.questionIndex,
    required this.answer,
  });
  @override
  List<Object?> get props => [questionKey, questionIndex, answer];
}

class SubmitBmiEvent extends AssessmentsEvent {
  final String weightKg;
  final String heightCm;
  const SubmitBmiEvent({required this.weightKg, required this.heightCm});
  @override
  List<Object?> get props => [weightKg, heightCm];
}

class PreviewBmiEvent extends AssessmentsEvent {
  final String weightKg;
  final String heightCm;
  const PreviewBmiEvent({required this.weightKg, required this.heightCm});
  @override
  List<Object?> get props => [weightKg, heightCm];
}

class ClearBmiPreviewEvent extends AssessmentsEvent {
  const ClearBmiPreviewEvent();
}

class FetchScoreEvent extends AssessmentsEvent {
  const FetchScoreEvent();
}

class ResetAssessmentsEvent extends AssessmentsEvent {
  const ResetAssessmentsEvent();
}
