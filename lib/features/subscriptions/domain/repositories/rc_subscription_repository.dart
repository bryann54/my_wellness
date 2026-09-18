import 'package:dartz/dartz.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_entitlement_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';

abstract class RCSubscriptionRepository {
  Future<Either<Failure, Unit>> initialize(String userId);

  Future<Either<Failure, List<RCPackage>>> getOfferings();

  Future<Either<Failure, Map<String, RCEntitlement>>> purchasePackage(
    RCPackage package,
  );
  Future<Either<Failure, Map<String, RCEntitlement>>> restorePurchases();

  Future<Either<Failure, Map<String, RCEntitlement>>> getEntitlements();

  Future<Either<Failure, bool>> hasEntitlement(String entitlementKey);

  Future<Either<Failure, Unit>> logOut();
}
