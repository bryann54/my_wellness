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
