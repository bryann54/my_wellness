import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/repositories/rc_subscription_repository.dart';

@injectable
class RCGetOfferingsUseCase implements UseCase<List<RCPackage>, NoParams> {
  final RCSubscriptionRepository _repository;
  const RCGetOfferingsUseCase(this._repository);

  @override
  Future<Either<Failure, List<RCPackage>>> call(NoParams params) =>
      _repository.getOfferings();
}
