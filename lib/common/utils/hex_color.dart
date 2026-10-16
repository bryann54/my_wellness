import 'package:flutter/material.dart';
Color hexToColor(String? hex, {Color fallback = Colors.grey}) {
  if (hex == null) return fallback;
  var cleaned = hex.trim().replaceFirst('#', '');
  if (cleaned.length == 6) cleaned = 'FF$cleaned';
  if (cleaned.length != 8) return fallback;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return fallback;
  return Color(value);
}
