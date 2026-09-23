import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLogInterceptor extends Interceptor {
  final bool printBody;

  DioLogInterceptor({this.printBody = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '--> REQUEST: ${options.method} '
      '${options.baseUrl}${options.path}',
    );

    if (printBody && options.data != null) {
      debugPrint('Payload: ${options.data}');
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '<-- RESPONSE: ${response.statusCode} '
      '${response.requestOptions.path}',
    );

    if (printBody && response.data != null) {
      debugPrint('Data: ${response.data}');
    }

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'XXX ERROR: ${err.response?.statusCode} '
      '${err.requestOptions.path}',
    );

    debugPrint('Message: ${err.message}');

    if (err.response?.data != null) {
      debugPrint('Error Details: ${err.response?.data}');
    }

    return super.onError(err, handler);
  }
}
