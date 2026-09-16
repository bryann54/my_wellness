import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/handlers/errors/failures.dart';
import 'package:my_wellness/core/api_client/client/dio_client.dart';

@lazySingleton
class ClientProvider {
  ClientProvider(this._client);

  final DioClient _client;

  Future<Response<T>> get<T>(String path) async {
    try {
      return await _client.dio.get<T>(path);
    } on DioException catch (error) {
      throw _mapFailure(error);
    }
  }

  Failure _mapFailure(DioException error) => switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          const NetworkFailure(),
        DioExceptionType.badResponse when error.response?.statusCode == 401 =>
          const UnauthorizedFailure(),
        _ => const UnexpectedFailure(),
      };
}
