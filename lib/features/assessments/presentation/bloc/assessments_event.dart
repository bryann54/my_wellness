part of 'assessments_bloc.dart';

abstract class AssessmentsEvent extends Equatable {
  const AssessmentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssessmentsEvent extends AssessmentsEvent {
  final String? userGender;
  final bool silent;
  const LoadAssessmentsEvent({required this.userGender, this.silent = false});
  @override
  List<Object?> get props => [userGender, silent];
}

class SearchAssessmentsEvent extends AssessmentsEvent {
  final String query;
  const SearchAssessmentsEvent(this.query);
  @override
  List<Object?> get props => [query];
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

class SubmitCancerPreScreeningEvent extends AssessmentsEvent {
  final String priorCancerHistory;
  final String priorCancerType;
  final int? priorCancerYear;
  const SubmitCancerPreScreeningEvent({
    required this.priorCancerHistory,
    required this.priorCancerType,
    this.priorCancerYear,
  });

  @override
  List<Object?> get props => [
    priorCancerHistory,
    priorCancerType,
    priorCancerYear,
  ];
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

class AlertNavigatorEvent extends AssessmentsEvent {
  const AlertNavigatorEvent();
}

class DownloadReportEvent extends AssessmentsEvent {
  final String email;
  final bool emailOnly;
  const DownloadReportEvent({this.email = '', this.emailOnly = false});
  @override
  List<Object?> get props => [email, emailOnly];
}

class ResetAssessmentsEvent extends AssessmentsEvent {
  const ResetAssessmentsEvent();
}
