import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/pricing/data/datasources/pricing_remote_data_source.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_catalog.dart';
import 'package:my_wellness/features/pricing/domain/entities/pricing_package.dart';
import 'package:my_wellness/features/pricing/domain/repositories/pricing_repository.dart';

@LazySingleton(as: PricingRepository)
class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource _remoteDataSource;
  final Map<String, Either<Failure, List<PricingPackage>>> _lastPackages = {};
  Either<Failure, PricingCatalog>? _lastCatalog;

  PricingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PricingPackage>>> getPackages({
    String? category,
    bool refresh = false,
  }) async {
    final cacheKey = category ?? '';
    if (!refresh && _lastPackages.containsKey(cacheKey)) {
      return _lastPackages[cacheKey]!;
    }
    try {
      final packages = await _remoteDataSource.getPackages(category: category);
      final entities = packages
          .map((package) => package.toEntity())
          .toList(growable: false);
      return _lastPackages[cacheKey] = Right(entities);
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, PricingCatalog>> getServiceCatalog({
    bool refresh = false,
  }) async {
    if (!refresh && _lastCatalog != null) return _lastCatalog!;
    try {
      return _lastCatalog = Right(
        (await _remoteDataSource.getServiceCatalog()).toEntity(),
      );
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, PricingQuote>> quote(
    Map<String, dynamic> selection,
  ) async {
    try {
      return Right((await _remoteDataSource.quote(selection)).quote);
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, PricingPayment>> checkout({
    required Map<String, dynamic> selection,
    required String phone,
    String? idempotencyKey,
  }) async {
    try {
      return Right(
        await _remoteDataSource.checkout(
          selection: selection,
          phone: phone,
          idempotencyKey: idempotencyKey,
        ),
      );
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, PricingPayment>> stkPush({
    required String phone,
    required int amount,
    required String serviceType,
    required String idempotencyKey,
    String? sessionId,
    String? bookingId,
    String? invoiceId,
    String? packageId,
    int? age,
  }) async {
    try {
      return Right(
        await _remoteDataSource.stkPush(
          phone: phone,
          amount: amount,
          serviceType: serviceType,
          idempotencyKey: idempotencyKey,
          sessionId: sessionId,
          bookingId: bookingId,
          invoiceId: invoiceId,
          packageId: packageId,
          age: age,
        ),
      );
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, List<PricingPayment>>> getMyPayments({
    String? cursor,
  }) async {
    try {
      return Right(await _remoteDataSource.getMyPayments(cursor: cursor));
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getUnlockedCategories() async {
    try {
      return Right(await _remoteDataSource.getUnlockedCategories());
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, bool>> hasVitalsLoggingAccess() async {
    try {
      return Right(await _remoteDataSource.hasVitalsLoggingAccess());
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getReceipts({
    String? cursor,
  }) async {
    try {
      return Right(await _remoteDataSource.getReceipts(cursor: cursor));
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> getReceiptPdf(String id) async {
    try {
      return Right(await _remoteDataSource.getReceiptPdf(id));
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getInvoices({
    String? cursor,
  }) async {
    try {
      return Right(await _remoteDataSource.getInvoices(cursor: cursor));
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  @override
  Future<Either<Failure, Uint8List>> getInvoicePdf(String id) async {
    try {
      return Right(await _remoteDataSource.getInvoicePdf(id));
    } on Exception catch (error) {
      return Left(_mapException(error));
    }
  }

  Failure _mapException(Exception error) => switch (error) {
    ApiValidationException(:final code, :final message, :final body) =>
      AssessmentFailure(error: message, code: code, body: body),
    UnauthorizedException() => const UnauthorizedFailure(),
    NetworkException() => const NetworkFailure(),
    NotFoundException(:final message) => NotFoundFailure(error: message),
    ValidationException(:final message) => ValidationFailure(error: message),
    ServerException() => const ServerFailure(),
    _ => GeneralFailure(error: error.toString()),
  };
}
