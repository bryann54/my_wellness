import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/repositories/account_repository.dart';

@lazySingleton
class ChangeLanguageUseCase implements UseCase<NoParams, String> {
  final AccountRepository _repository;
  ChangeLanguageUseCase(this._repository);

  @override
  Future<Either<Failure, NoParams>> call(String params) async {
    return await _repository.changeLanguage(params);
  }
}
