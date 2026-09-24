import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/assessments/data/datasources/assessments_remote_datasource.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_answer.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_definition.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_score.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_session.dart';
import 'package:my_wellness/features/assessments/domain/entities/assessment_summary.dart';
import 'package:my_wellness/features/assessments/domain/entities/bmi_preview.dart';
import 'package:my_wellness/features/assessments/domain/entities/vitals_access.dart';
import 'package:my_wellness/features/assessments/domain/repositories/assessments_repository.dart';

@LazySingleton(as: AssessmentsRepository)
class AssessmentRepositoryImpl implements AssessmentsRepository {
  final AssessmentsRemoteDataSource _remote;
  AssessmentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, VitalsAccess>> getVitalsAccess() async {
    try {
      return Right(await _remote.getVitalsAccess());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<AssessmentSummary>>> listAssessments() async {
    try {
      return Right(await _remote.listAssessments());
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, CanStartResult>> canStart(String slug) async {
    try {
      return Right(await _remote.canStart(slug));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, AssessmentDefinition>> getDefinition(
    String slug,
  ) async {
    try {
      return Right(await _remote.getDefinition(slug));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, AssessmentSession>> startSession(String slug) async {
    try {
      return Right(await _remote.startSession(slug));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, List<AssessmentAnswer>>> getAnswers(
    String slug,
    String sessionId,
  ) async {
    try {
      return Right(await _remote.getAnswers(slug, sessionId));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, SubmitAnswerResult>> submitAnswer(
    String slug,
    String sessionId, {
    required String questionKey,
    required int questionIndex,
    required String answer,
  }) async {
    try {
      return Right(
        await _remote.submitAnswer(
          slug,
          sessionId,
          questionKey: questionKey,
          questionIndex: questionIndex,
          answer: answer,
        ),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, bool>> submitBmiMetrics(
    String slug,
    String sessionId, {
    required String weightKg,
    required String heightCm,
  }) async {
    try {
      return Right(
        await _remote.submitBmiMetrics(
          slug,
          sessionId,
          weightKg: weightKg,
          heightCm: heightCm,
        ),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, AssessmentScore>> getScore(
    String slug,
    String sessionId,
  ) async {
    try {
      return Right(await _remote.getScore(slug, sessionId));
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, BmiPreview>> previewBmi({
    required String weightKg,
    required String heightCm,
  }) async {
    try {
      return Right(
        await _remote.previewBmi(weightKg: weightKg, heightCm: heightCm),
      );
    } on Exception catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(Exception e) {
    if (e is UnauthorizedException) return const UnauthorizedFailure();
    if (e is ValidationException) return ValidationFailure(error: e.message);
    if (e is NotFoundException) return NotFoundFailure(error: e.message);
    if (e is NetworkException) return const NetworkFailure();
    if (e is ServerException) return const ServerFailure();
    return GeneralFailure(error: e.toString());
  }
}
