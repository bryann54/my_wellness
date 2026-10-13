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
    final message = _extractMessage(data);

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

  /// Walks the response body and returns the first human-readable string.
  /// Handles the three shapes the backend emits:
  ///   1. { "detail": "string" }
  ///   2. { "field": ["msg1", "msg2"] }
  ///   3. { "error": { "detail": { "field": ["msg1", "msg2"] } } }
  String? _extractMessage(dynamic data) {
    if (data is! Map) return null;

    // Unwrap the "error" envelope if present.
    final body = data['error'] is Map ? data['error'] as Map : data;

    // Case 1: top-level detail string.
    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) return detail;

    // Case 3: nested detail map — recurse.
    if (detail is Map) {
      final nested = _extractMessage(detail);
      if (nested != null) return nested;
    }

    // Case 2: field → list-of-strings, joined into one message.
    final parts = <String>[];
    for (final entry in body.entries) {
      if (entry.key == 'status_code') continue;
      final v = entry.value;
      if (v is List && v.isNotEmpty) {
        parts.add(v.first.toString());
      } else if (v is String && v.isNotEmpty) {
        parts.add(v);
      } else if (v is Map) {
        final nested = _extractMessage(v);
        if (nested != null) parts.add(nested);
      }
    }

    return parts.isEmpty ? null : parts.join('\n');
  }
}
