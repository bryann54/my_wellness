import 'package:equatable/equatable.dart';
import 'assessment_cta.dart';
import 'assessment_question.dart';

class AssessmentDefinition extends Equatable {
  final String slug;
  final String category;
  final String title;
  final String shortTitle;
  final String tagline;
  final String? disclaimer;
  final String? referencePrefix;
  final String? understandingCopy;
  final List<AssessmentQuestion> questions;
  final List<AssessmentCta> ctas;

  const AssessmentDefinition({
    required this.slug,
    required this.category,
    required this.title,
    required this.shortTitle,
    required this.tagline,
    required this.questions,
    required this.ctas,
    this.disclaimer,
    this.referencePrefix,
    this.understandingCopy,
  });

  AssessmentQuestion? questionByIndex(int index) {
    for (final q in questions) {
      if (q.index == index) return q;
    }
    return null;
  }

  AssessmentQuestion? questionByKey(String key) {
    for (final q in questions) {
      if (q.key == key) return q;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    slug,
    category,
    title,
    shortTitle,
    tagline,
    disclaimer,
    referencePrefix,
    understandingCopy,
    questions,
    ctas,
  ];
}
