import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModules {
  @preResolve
  Future<SharedPreferences> prefs() async =>
      await SharedPreferences.getInstance();

  @Named('firebaseMessaging')
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
  @Named('firebaseDatabase')
  FirebaseDatabase get firebaseDatabase => FirebaseDatabase.instance;

  @Named('BaseUrl')
  String get baseUrl => dotenv.env['BASE_URL']!;

  @lazySingleton
  Dio dio(@Named('BaseUrl') String url) => Dio(
      BaseOptions(baseUrl: url, connectTimeout: const Duration(seconds: 10)));
}
