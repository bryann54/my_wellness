import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  String get message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
  @override
  String get message => 'A network connection is unavailable.';
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
  @override
  String get message => 'Your session is no longer available.';
}

final class ContractUnavailableFailure extends Failure {
  const ContractUnavailableFailure();
  @override
  String get message => 'This service is not available yet.';
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
  @override
  String get message => 'Something went wrong. Please try again later.';
}
