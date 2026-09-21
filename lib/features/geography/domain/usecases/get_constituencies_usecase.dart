import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/repositories/geography_repository.dart';

@lazySingleton
class GetConstituenciesUseCase
    implements UseCase<List<Constituency>, NoParams> {
  final GeographyRepository _repo;
  GetConstituenciesUseCase(this._repo);

  @override
  Future<Either<Failure, List<Constituency>>> call(NoParams params) =>
      _repo.getConstituencies();
}
