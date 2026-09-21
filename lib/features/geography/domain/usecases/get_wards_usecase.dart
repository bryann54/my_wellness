import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';
import 'package:my_wellness/features/geography/domain/repositories/geography_repository.dart';

@lazySingleton
class GetWardsUseCase implements UseCase<List<Ward>, NoParams> {
  final GeographyRepository _repo;
  GetWardsUseCase(this._repo);

  @override
  Future<Either<Failure, List<Ward>>> call(NoParams params) => _repo.getWards();
}
