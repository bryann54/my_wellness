part of 'subscriptions_bloc.dart';

enum SubscriptionStatus {
  initial,
  loading,
  ready, // offerings loaded
  purchasing,
  restoring,
  success, // purchase / restore succeeded
  error,
}

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final List<RCPackage> offerings;
  final Map<String, RCEntitlement> entitlements;
  final String? errorMessage;
  final String? successMessage;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.offerings = const [],
    this.entitlements = const {},
    this.errorMessage,
    this.successMessage,
  });

  bool get isPremium =>
      entitlements.containsKey('premium'); // ← your entitlement key

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    List<RCPackage>? offerings,
    Map<String, RCEntitlement>? entitlements,
    String? errorMessage,
    String? successMessage,
  }) => SubscriptionState(
    status: status ?? this.status,
    offerings: offerings ?? this.offerings,
    entitlements: entitlements ?? this.entitlements,
    errorMessage:
        errorMessage, // intentionally not null-coalesced (clears on success)
    successMessage: successMessage,
  );

  @override
  List<Object?> get props => [
    status,
    offerings,
    entitlements,
    errorMessage,
    successMessage,
  ];
}
