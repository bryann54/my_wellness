import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';
import 'package:my_wellness/features/health_profile/domain/repositories/health_history_repository.dart';

@lazySingleton
class GetHealthHistoryUseCase implements UseCase<HealthHistory, NoParams> {
  const GetHealthHistoryUseCase(this._repository);

  final HealthHistoryRepository _repository;

  @override
  Future<Either<Failure, HealthHistory>> call(NoParams params) =>
      _repository.load();
}
