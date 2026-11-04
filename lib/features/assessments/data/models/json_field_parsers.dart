import 'dart:convert';

String? ruleFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return jsonEncode(value);
}

String? beforeYouBeginFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is! List) return null;

  final paragraphs = <String>[];
  for (final page in value) {
    if (page is! Map) continue;
    final heading = (page['heading'] as String?)?.trim() ?? '';
    final body = (page['body'] as String?)?.trim() ?? '';
    if (heading.isNotEmpty) paragraphs.add(heading);
    if (body.isNotEmpty) paragraphs.add(body);
  }
  return paragraphs.isEmpty ? null : paragraphs.join('\n\n');
}

String? encouragingFactFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map) {
    final text = (value['text'] as String?)?.trim();
    return (text == null || text.isEmpty) ? null : text;
  }
  return null;
}
