import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_entitlement_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/repositories/rc_subscription_repository.dart';

@injectable
class RCRestorePurchasesUseCase
    implements UseCase<Map<String, RCEntitlement>, NoParams> {
  final RCSubscriptionRepository _repository;
  const RCRestorePurchasesUseCase(this._repository);

  @override
  Future<Either<Failure, Map<String, RCEntitlement>>> call(NoParams params) =>
      _repository.restorePurchases();
}
