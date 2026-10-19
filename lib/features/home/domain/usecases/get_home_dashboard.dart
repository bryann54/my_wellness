import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';
import 'package:my_wellness/features/home/domain/repositories/home_dashboard_repository.dart';

@lazySingleton
class GetHomeDashboardUseCase
    implements UseCase<List<DashboardSession>, NoParams> {
  GetHomeDashboardUseCase(this._repository);

  final HomeDashboardRepository _repository;

  @override
  Future<Either<Failure, List<DashboardSession>>> call(NoParams params) =>
      _repository.loadRelevantSessions();
}
