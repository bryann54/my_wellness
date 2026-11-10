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
  final String? code;
  final Map<String, dynamic>? details;

  ValidationException(this.message, {this.code, this.details});
}

class ConflictException implements Exception {
  final String message;
  const ConflictException({this.message = 'Conflict'});
}

class PaymentRequiredException implements Exception {
  final String code;
  final String? message;
  const PaymentRequiredException({
    this.code = 'vitals_access_required',
    this.message,
  });
}
