// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentSummaryModel _$AssessmentSummaryModelFromJson(
  Map<String, dynamic> json,
) => AssessmentSummaryModel(
  slug: json['slug'] as String,
  category: json['category'] as String,
  title: json['title'] as String,
  shortTitle: json['short_title'] as String,
  tagline: json['tagline'] as String,
  excludedGender: json['excluded_gender'] as String?,
);

Map<String, dynamic> _$AssessmentSummaryModelToJson(
  AssessmentSummaryModel instance,
) => <String, dynamic>{
  'slug': instance.slug,
  'category': instance.category,
  'title': instance.title,
  'short_title': instance.shortTitle,
  'tagline': instance.tagline,
  'excluded_gender': instance.excludedGender,
};
