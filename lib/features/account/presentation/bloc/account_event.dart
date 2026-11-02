part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends AccountEvent {
  const FetchProfileEvent();
}

class UpdateProfileEvent extends AccountEvent {
  final Map<String, dynamic> updatedData;
  const UpdateProfileEvent({required this.updatedData});

  @override
  List<Object?> get props => [updatedData];
}

class DeclareCancerDiagnosisEvent extends AccountEvent {
  final bool declared;
  final bool? educationMaterials;
  const DeclareCancerDiagnosisEvent({
    required this.declared,
    this.educationMaterials,
  });

  @override
  List<Object?> get props => [declared, educationMaterials];
}

class DeleteAccountEvent extends AccountEvent {
  const DeleteAccountEvent();
}

class CancelAccountDeletionEvent extends AccountEvent {
  const CancelAccountDeletionEvent();
}

class ExportDataEvent extends AccountEvent {
  const ExportDataEvent();
}

class ChangeLanguageEvent extends AccountEvent {
  final String langCode;
  const ChangeLanguageEvent({required this.langCode});

  @override
  List<Object?> get props => [langCode];
}

class ClearErrorEvent extends AccountEvent {
  const ClearErrorEvent();
}
