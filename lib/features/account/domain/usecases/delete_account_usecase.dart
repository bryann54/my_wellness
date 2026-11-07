import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/repositories/account_repository.dart';

@injectable
class DeleteAccountUseCase {
  final AccountRepository _repository;
  const DeleteAccountUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String password) async {
    final result = await _repository.deleteAccount(password);
    return result.fold((f) => Left(f), (_) => const Right(unit));
  }
}
