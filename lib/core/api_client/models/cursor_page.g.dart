// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'cursor_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CursorPage<T> _$CursorPageFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => CursorPage<T>(
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
);

Map<String, dynamic> _$CursorPageToJson<T>(
  CursorPage<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map(toJsonT).toList(),
};
