import 'package:flutter/material.dart';

abstract final class ClassificationColors {
  static const Color green = Color(0xFF10B981);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color orange = Color(0xFFF97316);
  static const Color red = Color(0xFFDC2626);
  static const Color blue = Color(0xFF3B82F6);
  static const Color neutral = Color(0xFF94A3B8);

  static Color forBand(String classification) {
    final base = classification.split('_').first.toLowerCase();
    return switch (base) {
      'green' => green,
      'yellow' => yellow,
      'orange' => orange,
      'red' => red,
      'blue' => blue,
      _ => neutral,
    };
  }
}

Color classificationColor(String classification) =>
    ClassificationColors.forBand(classification);
