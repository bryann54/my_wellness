import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/repositories/geography_repository.dart';

@lazySingleton
class GetCountiesUseCase implements UseCase<List<County>, NoParams> {
  final GeographyRepository _repo;
  GetCountiesUseCase(this._repo);

  @override
  Future<Either<Failure, List<County>>> call(NoParams params) =>
      _repo.getCounties();
}
