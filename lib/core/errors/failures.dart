// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure();
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class GeneralFailure extends Failure {
  final String error;
  const GeneralFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

class NotFoundFailure extends Failure {
  final String error;
  const NotFoundFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ValidationFailure extends Failure {
  final String error;
  const ValidationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ConflictFailure extends Failure {
  final String? error;
  const ConflictFailure({this.error});

  @override
  List<Object?> get props => [error];
}

class AssessmentFailure extends ValidationFailure {
  final String? code;
  final Map<String, dynamic> body;
  const AssessmentFailure({
    required super.error,
    this.code,
    this.body = const {},
  });

  String? get blockingSlug => body['blocking_slug'] as String?;
  String? get blockingTitle => body['blocking_title'] as String?;
  String? get dependantVariantSlug => body['dependant_variant_slug'] as String?;

  @override
  List<Object?> get props => [error, code, body];
}

class AssessmentValidationFailure extends ValidationFailure {
  final String? code;
  final String? blockingSlug;
  final String? blockingTitle;
  final String? dependantVariantSlug;

  const AssessmentValidationFailure({
    required super.error,
    this.code,
    this.blockingSlug,
    this.blockingTitle,
    this.dependantVariantSlug,
  });

  @override
  List<Object?> get props => [
    error,
    code,
    blockingSlug,
    blockingTitle,
    dependantVariantSlug,
  ];
}
