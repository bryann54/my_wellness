import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/subscriptions/data/datasources/rc_subscription_datasource.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_entitlement_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/repositories/rc_subscription_repository.dart';

@LazySingleton(as: RCSubscriptionRepository)
class RCSubscriptionRepositoryImpl implements RCSubscriptionRepository {
  final RCSubscriptionDatasource _datasource;
  const RCSubscriptionRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, Unit>> initialize(String userId) =>
      _guardUnit(() => _datasource.initialize(userId));

  @override
  Future<Either<Failure, List<RCPackage>>> getOfferings() =>
      _guard(() => _datasource.getOfferings());

  @override
  Future<Either<Failure, Map<String, RCEntitlement>>> purchasePackage(
    RCPackage package,
  ) => _guard(() => _datasource.purchasePackage(package));

  @override
  Future<Either<Failure, Map<String, RCEntitlement>>> restorePurchases() =>
      _guard(() => _datasource.restorePurchases());

  @override
  Future<Either<Failure, Map<String, RCEntitlement>>> getEntitlements() =>
      _guard(() => _datasource.getEntitlements());

  @override
  Future<Either<Failure, bool>> hasEntitlement(String entitlementKey) async {
    final result = await getEntitlements();
    return result.map(
      (entitlements) => entitlements.containsKey(entitlementKey),
    );
  }

  @override
  Future<Either<Failure, Unit>> logOut() =>
      _guardUnit(() => _datasource.logOut());

  // ── Guards (mirror your existing pattern) ───────────────

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(error: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _guardUnit(Future<void> Function() fn) async {
    try {
      await fn();
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(error: e.message));
    } catch (e) {
      return Left(GeneralFailure(error: e.toString()));
    }
  }
}
