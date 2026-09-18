import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/domain/repositories/account_repository.dart';

@lazySingleton
class GetProfileUsecase implements UseCase<HealthProfile, NoParams> {
  final AccountRepository _repository;
  GetProfileUsecase(this._repository);

  @override
  Future<Either<Failure, HealthProfile>> call(NoParams params) async {
    return await _repository.getProfile();
  }
}
