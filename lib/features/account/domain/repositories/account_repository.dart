import 'package:dartz/dartz.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';

abstract class AccountRepository {
  Future<Either<Failure, HealthProfile>> getProfile();
  Future<Either<Failure, HealthProfile>> updateProfile(
    Map<String, dynamic> data,
  );
  Future<Either<Failure, NoParams>> changeLanguage(String code);
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> cancelAccountDeletion();
  Future<Either<Failure, void>> exportData();
}
