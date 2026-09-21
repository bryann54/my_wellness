// lib/core/api_client/client/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/interceptors/auth_interceptor.dart';
import 'package:my_wellness/core/api_client/interceptors/logging_interceptor.dart';
import 'package:my_wellness/core/errors/exceptions.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;

  static Options get protected => Options(headers: {'requiresToken': true});
  static Options get open => Options(headers: {'requiresToken': false});

  ApiClient(@Named('BaseUrl') String baseUrl, AuthInterceptor authInterceptor)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          contentType: Headers.jsonContentType,
        ),
      ) {
    _dio.interceptors.addAll([
      DioLogInterceptor(printBody: kDebugMode),
      authInterceptor,
    ]);
  }

  Future<T> get<T>({
    required String url,
    Map<String, dynamic>? query,
    Options? options,
  }) => _request(() => _dio.get(url, queryParameters: query, options: options));

  Future<T> post<T>({required String url, dynamic payload, Options? options}) =>
      _request(() => _dio.post(url, data: payload, options: options));

  Future<T> put<T>({required String url, dynamic payload, Options? options}) =>
      _request(() => _dio.put(url, data: payload, options: options));

  Future<T> patch<T>({
    required String url,
    dynamic payload,
    Options? options,
  }) => _request(() => _dio.patch(url, data: payload, options: options));

  Future<T> delete<T>({
    required String url,
    dynamic payload,
    Options? options,
  }) => _request(() => _dio.delete(url, data: payload, options: options));

  Future<T> _request<T>(Future<Response> Function() apiCall) async {
    try {
      final response = await apiCall();
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Stream<List<int>>> postStream({
    required String url,
    dynamic payload,
    Options? options,
  }) async {
    final response = await _dio.post<ResponseBody>(
      url,
      data: payload,
      options: (options ?? Options()).copyWith(
        responseType: ResponseType.stream,
      ),
    );
    return response.data!.stream;
  }

  Future<T> postFormData<T>({
    required String url,
    required FormData formData,
    Options? options,
  }) => _request(
    () => _dio.post(
      url,
      data: formData,
      options: (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(seconds: 60),
      ),
    ),
  );

  Exception _handleDioError(DioException e) {
    final data = e.response?.data;
    String? message;

    if (data is Map) {
      final errorContent =
          data['non_field_errors'] ?? data['detail'] ?? data['message'] ?? data;
      if (errorContent is List && errorContent.isNotEmpty) {
        message = errorContent.first.toString();
      } else if (errorContent is Map) {
        message = errorContent.values.first.toString();
      } else {
        message = errorContent.toString();
      }
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException('Check your internet connection');
    }

    return switch (e.response?.statusCode) {
      400 => ValidationException(message ?? 'Invalid request'),
      401 => UnauthorizedException(message ?? 'Session expired'),
      404 => NotFoundException(message ?? 'Resource not found'),
      409 => ConflictException(message: message ?? 'Conflict occurred'),
      _ => ServerException(message ?? 'Something went wrong'),
    };
  }
}
