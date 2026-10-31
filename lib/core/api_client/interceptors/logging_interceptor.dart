import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLogInterceptor extends Interceptor {
  DioLogInterceptor({bool printBody = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '--> REQUEST: ${options.method} '
      '${options.baseUrl}${options.path}',
    );

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '<-- RESPONSE: ${response.statusCode} '
      '${response.requestOptions.path}',
    );

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'XXX ERROR: ${err.response?.statusCode} '
      '${err.requestOptions.path}',
    );

    return super.onError(err, handler);
  }
}
