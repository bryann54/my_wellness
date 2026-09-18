import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:my_wellness/core/errors/exceptions.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_entitlement_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';

abstract class RCSubscriptionDatasource {
  Future<void> initialize(String userId);
  Future<List<RCPackage>> getOfferings();
  Future<Map<String, RCEntitlement>> purchasePackage(RCPackage package);
  Future<Map<String, RCEntitlement>> restorePurchases();
  Future<Map<String, RCEntitlement>> getEntitlements();
  Future<void> logOut();
}

@LazySingleton(as: RCSubscriptionDatasource)
class RCSubscriptionDatasourceImpl implements RCSubscriptionDatasource {
  final String _apiKey;

  RCSubscriptionDatasourceImpl(@Named('rcApiKey') this._apiKey);

  @override
  Future<void> initialize(String userId) async {
    await rc.Purchases.setLogLevel(
      kReleaseMode ? rc.LogLevel.error : rc.LogLevel.debug,
    );
    await rc.Purchases.configure(
      rc.PurchasesConfiguration(_apiKey)..appUserID = userId,
    );
  }

  @override
  Future<List<RCPackage>> getOfferings() async {
    try {
      final offerings = await rc.Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return [];
      return current.availablePackages.map(_mapPackage).toList();
    } on PlatformException catch (e) {
      _throwMapped(e);
    }
  }

  @override
  Future<Map<String, RCEntitlement>> purchasePackage(RCPackage package) async {
    try {
      final offerings = await rc.Purchases.getOfferings();
      final sdkPackage = offerings.current?.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == package.productIdentifier,
      );
      if (sdkPackage == null) throw NotFoundException('Package not found');
      final result = await rc.Purchases.purchasePackage(sdkPackage);
      return _mapEntitlements(result.customerInfo.entitlements.active);
    } on PlatformException catch (e) {
      _throwMapped(e);
    }
  }

  @override
  Future<Map<String, RCEntitlement>> restorePurchases() async {
    try {
      final customerInfo = await rc.Purchases.restorePurchases();
      return _mapEntitlements(customerInfo.entitlements.active);
    } on PlatformException catch (e) {
      _throwMapped(e);
    }
  }

  @override
  Future<Map<String, RCEntitlement>> getEntitlements() async {
    try {
      final customerInfo = await rc.Purchases.getCustomerInfo();
      return _mapEntitlements(customerInfo.entitlements.active);
    } on PlatformException catch (e) {
      _throwMapped(e);
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await rc.Purchases.logOut();
    } on PlatformException catch (e) {
      _throwMapped(e);
    }
  }

  RCPackage _mapPackage(rc.Package p) {
    return RCPackage(
      identifier: p.identifier,
      packageType: _mapPackageType(p.packageType),
      productIdentifier: p.storeProduct.identifier,
      localizedPriceString: p.storeProduct.priceString,
      localizedTitle: p.storeProduct.title,
      localizedDescription: p.storeProduct.description,
    );
  }

  // SDK's rc.PackageType
  RCPackageType _mapPackageType(rc.PackageType type) {
    switch (type) {
      case rc.PackageType.monthly:
        return RCPackageType.monthly;
      case rc.PackageType.annual:
        return RCPackageType.annual;
      case rc.PackageType.weekly:
        return RCPackageType.weekly;
      case rc.PackageType.lifetime:
        return RCPackageType.lifetime;
      default:
        return RCPackageType.unknown;
    }
  }

  Map<String, RCEntitlement> _mapEntitlements(
    Map<String, rc.EntitlementInfo> active,
  ) {
    return active.map(
      (key, info) => MapEntry(
        key,
        RCEntitlement(
          identifier: info.identifier,
          isActive: info.isActive,
          expirationDate: info.expirationDate != null
              ? DateTime.parse(info.expirationDate!)
              : null,
          productIdentifier: info.productIdentifier,
          store: info.store.name,
        ),
      ),
    );
  }

  Never _throwMapped(PlatformException e) {
    final code = rc.PurchasesErrorHelper.getErrorCode(e);
    switch (code) {
      case rc.PurchasesErrorCode.purchaseCancelledError:
        throw ValidationException('Purchase cancelled');
      case rc.PurchasesErrorCode.networkError:
        throw NetworkException();
      case rc.PurchasesErrorCode.purchaseNotAllowedError:
        throw ValidationException('Purchase not allowed');
      case rc.PurchasesErrorCode.receiptAlreadyInUseError:
        throw ValidationException('Receipt already in use by another account');
      default:
        throw ServerException(e.message ?? 'RevenueCat error');
    }
  }
}
