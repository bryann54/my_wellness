part of 'subscriptions_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class InitializeRC extends SubscriptionEvent {
  final String userId;
  const InitializeRC(this.userId);
  @override
  List<Object?> get props => [userId];
}

class LoadOfferings extends SubscriptionEvent {}

class PurchasePackage extends SubscriptionEvent {
  final RCPackage package;
  const PurchasePackage(this.package);
  @override
  List<Object?> get props => [package];
}

class RestorePurchases extends SubscriptionEvent {}

class LoadEntitlements extends SubscriptionEvent {}

class RCLogOut extends SubscriptionEvent {}
