import 'package:flutter/material.dart';

ThemeData myWellnessTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176B5B)),
      scaffoldBackgroundColor: const Color(0xffFAFAF8),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
