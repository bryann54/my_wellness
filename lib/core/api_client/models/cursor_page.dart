import 'package:json_annotation/json_annotation.dart';

part 'cursor_page.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class CursorPage<T> {
  final String? next;
  final String? previous;
  final List<T> results;

  CursorPage({this.next, this.previous, required this.results});

  factory CursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$CursorPageFromJson(json, fromJsonT);

  String? get nextCursor {
    final n = next;
    if (n == null) return null;
    return Uri.tryParse(n)?.queryParameters['cursor'];
  }
}
