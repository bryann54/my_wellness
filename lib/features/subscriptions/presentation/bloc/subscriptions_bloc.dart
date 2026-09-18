import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_entitlement_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/entities/rc_package_entity.dart';
import 'package:my_wellness/features/subscriptions/domain/usecases/rc_get_entitlements_usecase.dart';
import 'package:my_wellness/features/subscriptions/domain/usecases/rc_get_offerings_usecase.dart';
import 'package:my_wellness/features/subscriptions/domain/usecases/rc_purchase_package_usecase.dart';
import 'package:my_wellness/features/subscriptions/domain/usecases/rc_restore_purchases_usecase.dart';
import 'package:my_wellness/features/subscriptions/domain/repositories/rc_subscription_repository.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';

part 'subscriptions_event.dart';
part 'subscriptions_state.dart';

@injectable
class SubscriptionsBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final RCSubscriptionRepository _repository;
  final RCGetOfferingsUseCase _getOfferings;
  final RCPurchasePackageUseCase _purchasePackage;
  final RCRestorePurchasesUseCase _restorePurchases;
  final RCGetEntitlementsUseCase _getEntitlements;

  SubscriptionsBloc(
    this._repository,
    this._getOfferings,
    this._purchasePackage,
    this._restorePurchases,
    this._getEntitlements,
  ) : super(const SubscriptionState()) {
    on<InitializeRC>(_onInitialize);
    on<LoadOfferings>(_onLoadOfferings);
    on<PurchasePackage>(_onPurchasePackage);
    on<RestorePurchases>(_onRestorePurchases);
    on<LoadEntitlements>(_onLoadEntitlements);
    on<RCLogOut>(_onLogOut);
  }
  bool _rcInitialized = false;

  Future<void> _onInitialize(
    InitializeRC event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    final initResult = await _repository.initialize(event.userId);
    await initResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (_) async {
        _rcInitialized = true;
        final Either<Failure, List<RCPackage>> offeringsResult =
            await _getOfferings(NoParams());
        final Either<Failure, Map<String, RCEntitlement>> entitlementsResult =
            await _getEntitlements(NoParams());

        final offerings = offeringsResult.getOrElse(() => <RCPackage>[]);
        final entitlements = entitlementsResult.getOrElse(
          () => <String, RCEntitlement>{},
        );

        emit(
          state.copyWith(
            status: SubscriptionStatus.ready,
            offerings: offerings,
            entitlements: entitlements,
          ),
        );
      },
    );
  }

  Future<void> _onLoadOfferings(
    LoadOfferings event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (!_rcInitialized) return; // ← guard
    emit(state.copyWith(status: SubscriptionStatus.loading));
    final result = await _getOfferings(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (packages) => emit(
        state.copyWith(status: SubscriptionStatus.ready, offerings: packages),
      ),
    );
  }

  Future<void> _onLoadEntitlements(
    LoadEntitlements event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (!_rcInitialized) return; // ← guard
    final result = await _getEntitlements(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (entitlements) => emit(
        state.copyWith(
          status: SubscriptionStatus.ready,
          entitlements: entitlements,
        ),
      ),
    );
  }

  Future<void> _onPurchasePackage(
    PurchasePackage event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (!_rcInitialized) return;
    emit(state.copyWith(status: SubscriptionStatus.purchasing));
    final result = await _purchasePackage(RCPurchaseParams(event.package));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (entitlements) => emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          entitlements: entitlements,
          successMessage: 'Purchase successful! Enjoy your subscription.',
        ),
      ),
    );
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (!_rcInitialized) return;
    emit(state.copyWith(status: SubscriptionStatus.restoring));
    final result = await _restorePurchases(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: mapFailure(failure),
        ),
      ),
      (entitlements) => emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          entitlements: entitlements,
          successMessage: entitlements.isNotEmpty
              ? 'Purchases restored successfully.'
              : 'No active purchases found to restore.',
        ),
      ),
    );
  }

  Future<void> _onLogOut(
    RCLogOut event,
    Emitter<SubscriptionState> emit,
  ) async {
    await _repository.logOut();
    emit(const SubscriptionState());
  }
}
