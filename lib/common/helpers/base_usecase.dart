// lib/core/usecases/usecase.dart

import 'package:my_wellness/core/errors/failures.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type?>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

class FetchParams extends Equatable {
  final int? page;
  final int? size;
  final String? alerts;
  final int? incidents;
  final String? query;

  const FetchParams({
    this.page,
    this.size,
    this.query,
    this.alerts,
    this.incidents,
  });

  @override
  List<Object?> get props => [page, size, query];

  @override
  String toString() =>
      'FetchParams(page: $page, size: $size, query: $query, incidents: $incidents,)';
}
