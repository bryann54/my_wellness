// GENERATED CODE - DO NOT MODIFY BY HAND

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
