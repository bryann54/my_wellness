// lib/core/api_client/interceptors/auth_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/api_client/endpoints/api_endpoints.dart';
import 'package:my_wellness/features/auth/data/datasources/auth_local_datasource.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final Dio _refreshDio;

  Completer<String?>? _refreshTokenCompleter;

  AuthInterceptor(this._localDataSource, @Named('BaseUrl') String baseUrl)
    : _refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool requiresToken = options.headers['requiresToken'] ?? true;

    if (!requiresToken) {
      options.headers.remove('requiresToken');
      return handler.next(options);
    }

    final accessToken = await _localDataSource.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    options.headers.remove('requiresToken');
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.contains(ApiEndpoints.authTokenRefresh)) {
        await _localDataSource.clearAuthData();
        return handler.next(err);
      }

      final newToken = await _handleTokenRefresh();

      if (newToken != null) {
        return handler.resolve(await _retry(err.requestOptions, newToken));
      } else {
        await _localDataSource.clearAuthData();
      }
    }
    return handler.next(err);
  }

  Future<String?> _handleTokenRefresh() async {
    if (_refreshTokenCompleter != null &&
        !_refreshTokenCompleter!.isCompleted) {
      return _refreshTokenCompleter!.future;
    }

    _refreshTokenCompleter = Completer<String?>();

    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) throw Exception('No Refresh Token');

      final response = await _refreshDio.post(
        ApiEndpoints.authTokenRefresh,
        data: {'refresh': refreshToken},
      );

      final access = response.data['access'] as String?;
      if (access == null) {
        throw Exception('No access token in refresh response');
      }

      // Server may or may not rotate the refresh token.
      final refresh = (response.data['refresh'] as String?) ?? refreshToken;

      await _localDataSource.saveTokens(access: access, refresh: refresh);

      _refreshTokenCompleter!.complete(access);
      return access;
    } catch (_) {
      _refreshTokenCompleter!.complete(null);
      return null;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions, String token) async {
    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );
    return _refreshDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
