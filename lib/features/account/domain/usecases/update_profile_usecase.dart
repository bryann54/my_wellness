import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/domain/repositories/account_repository.dart';

@injectable
class UpdateProfileUseCase
    implements UseCase<HealthProfile, Map<String, dynamic>> {
  final AccountRepository _repository;
  const UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, HealthProfile>> call(Map<String, dynamic> params) {
    return _repository.updateProfile(params);
  }
}
