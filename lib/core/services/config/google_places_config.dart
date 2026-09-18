import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GooglePlacesConfig {
  GooglePlacesConfig._();

  static String get apiKey => Platform.isAndroid
      ? dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? ''
      : dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? '';
}
