import 'package:flutter/material.dart';

Color classificationColor(String classification) => switch (classification) {
  'green' => const Color(0xFF10B981),
  'yellow' => const Color(0xFFF59E0B),
  'orange' => const Color(0xFFF97316),
  'red' => const Color(0xFFDC2626),
  'blue' => const Color(0xFF3B82F6),
  _ => const Color(0xFF94A3B8),
};
