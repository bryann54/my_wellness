import 'dart:convert';
import 'package:my_wellness/features/assessments/data/models/assessment_definition_model.dart';

String? ruleFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  return jsonEncode(value);
}

/// The backend sends `before_you_begin` as a **list** of `{heading, body}`
/// pages on the definition payload. We also defensively accept the older
/// string/map shape so existing cached responses don't crash.
List<BeforeYouBeginPageModel> beforeYouBeginPagesFromJson(Object? value) {
  if (value == null) return const [];
  if (value is! List) return const [];

  final out = <BeforeYouBeginPageModel>[];
  for (final page in value) {
    if (page is! Map) continue;
    final heading = (page['heading'] as String?)?.trim() ?? '';
    final body = (page['body'] as String?)?.trim() ?? '';
    if (heading.isEmpty && body.isEmpty) continue;
    out.add(BeforeYouBeginPageModel(heading: heading, body: body));
  }
  return out;
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
