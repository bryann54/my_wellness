import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/home/domain/entities/dashboard_session.dart';

abstract class HomeDashboardRepository {
  Future<Either<Failure, List<DashboardSession>>> loadRelevantSessions();
}
