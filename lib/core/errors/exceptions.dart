// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}

class NetworkException implements Exception {
  final String? message;
  NetworkException([this.message]);
}

class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException([this.message = 'Unauthorized']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class ClientException implements Exception {
  final String message;
  ClientException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class ConflictException implements Exception {
  final String message;
  const ConflictException({this.message = 'Conflict'});
}

class ApiValidationException extends ValidationException {
  final String? code;
  final Map<String, dynamic> body;

  ApiValidationException(super.message, {this.code, this.body = const {}});

  String? get blockingSlug => body['blocking_slug'] as String?;
  String? get blockingTitle => body['blocking_title'] as String?;
  String? get dependantVariantSlug => body['dependant_variant_slug'] as String?;
}

({String? code, Map<String, dynamic> body}) parseApiErrorBody(dynamic data) {
  if (data is! Map) return (code: null, body: const {});
  final body = data['error'] is Map
      ? Map<String, dynamic>.from(data['error'] as Map)
      : Map<String, dynamic>.from(data);
  final code = body['code'] as String?;
  return (code: code, body: body);
}
