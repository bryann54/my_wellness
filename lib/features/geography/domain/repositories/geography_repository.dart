import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/geography/domain/entities/constituency.dart';
import 'package:my_wellness/features/geography/domain/entities/county.dart';
import 'package:my_wellness/features/geography/domain/entities/sub_county.dart';
import 'package:my_wellness/features/geography/domain/entities/ward.dart';

abstract class GeographyRepository {
  Future<Either<Failure, List<County>>> getCounties();
  Future<Either<Failure, List<SubCounty>>> getSubCounties();
  Future<Either<Failure, List<Constituency>>> getConstituencies();
  Future<Either<Failure, List<Ward>>> getWards();
}
