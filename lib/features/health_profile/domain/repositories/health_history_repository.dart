import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/health_profile/domain/entities/health_history.dart';

abstract class HealthHistoryRepository {
  Future<Either<Failure, HealthHistory>> load();
}
