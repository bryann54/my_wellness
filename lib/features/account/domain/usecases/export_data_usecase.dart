// lib/features/account/domain/usecases/export_data_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/account/domain/repositories/account_repository.dart';

@injectable
class ExportDataUseCase implements UseCase<Unit, NoParams> {
  final AccountRepository _repository;
  const ExportDataUseCase(this._repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    final result = await _repository.exportData();
    return result.fold((f) => Left(f), (_) => const Right(unit));
  }
}
