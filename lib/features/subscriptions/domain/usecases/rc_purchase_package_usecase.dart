import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_entitlement_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/repositories/rc_subscription_repository.dart';

class RCPurchaseParams {
  final RCPackage package;
  const RCPurchaseParams(this.package);
}

@injectable
class RCPurchasePackageUseCase
    implements UseCase<Map<String, RCEntitlement>, RCPurchaseParams> {
  final RCSubscriptionRepository _repository;
  const RCPurchasePackageUseCase(this._repository);

  @override
  Future<Either<Failure, Map<String, RCEntitlement>>> call(
    RCPurchaseParams params,
  ) =>
      _repository.purchasePackage(params.package);
}
