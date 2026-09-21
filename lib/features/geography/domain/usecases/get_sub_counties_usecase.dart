import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/repositories/geography_repository.dart';

@lazySingleton
class GetSubCountiesUseCase implements UseCase<List<SubCounty>, NoParams> {
  final GeographyRepository _repo;
  GetSubCountiesUseCase(this._repo);

  @override
  Future<Either<Failure, List<SubCounty>>> call(NoParams params) =>
      _repo.getSubCounties();
}
