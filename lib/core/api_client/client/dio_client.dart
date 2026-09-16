import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/config/api_config.dart';

@lazySingleton
class DioClient {
  DioClient(ApiConfig config)
      : dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            headers: const {'Content-Type': 'application/json'},
          ),
        );

  final Dio dio;
}
