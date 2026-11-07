import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Swahili expose the same localization keys', () {
    final english = _readLocale('assets/lang/en.json');
    final swahili = _readLocale('assets/lang/sw.json');

    expect(_leafKeys(swahili), _leafKeys(english));
    expect(
      _leafValues(swahili).where((value) => value.trim().isEmpty),
      isEmpty,
      reason: 'Localized UI strings must not be blank.',
    );
  });
}

Map<String, dynamic> _readLocale(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  return decoded as Map<String, dynamic>;
}

Set<String> _leafKeys(Map<String, dynamic> source, [String prefix = '']) {
  final keys = <String>{};
  for (final entry in source.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      keys.addAll(_leafKeys(value, key));
    } else {
      keys.add(key);
    }
  }
  return keys;
}

Iterable<String> _leafValues(Map<String, dynamic> source) sync* {
  for (final value in source.values) {
    if (value is Map<String, dynamic>) {
      yield* _leafValues(value);
    } else if (value is String) {
      yield value;
    }
  }
}
