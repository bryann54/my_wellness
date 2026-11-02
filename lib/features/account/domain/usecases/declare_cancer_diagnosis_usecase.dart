import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/domain/repositories/account_repository.dart';

@lazySingleton
class DeclareCancerDiagnosisUseCase {
  final AccountRepository _repository;
  DeclareCancerDiagnosisUseCase(this._repository);

  Future<Either<Failure, HealthProfile>> call({
    required bool declared,
    bool? educationMaterials,
  }) => _repository.declareCancerDiagnosis(
    declared: declared,
    educationMaterials: educationMaterials,
  );
}
