// lib/core/models/paginated_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int count;
  final List<T> results;

  PaginatedResponse({
    required this.page,
    required this.perPage,
    required this.count,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}
