// lib/features/account/presentation/bloc/account_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/common/utils/functions.dart';
import 'package:my_wellness/features/account/domain/entities/health_profile.dart';
import 'package:my_wellness/features/account/domain/usecases/cancel_account_deletion_usecase.dart';
import 'package:my_wellness/features/account/domain/usecases/change_language_usecase.dart';
import 'package:my_wellness/features/account/domain/usecases/delete_account_usecase.dart';
import 'package:my_wellness/features/account/domain/usecases/export_data_usecase.dart';
import 'package:my_wellness/features/account/domain/usecases/get_profile_usecase.dart';
import 'package:my_wellness/features/account/domain/usecases/update_profile_usecase.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/subscriptions/presentation/bloc/subscriptions_bloc.dart';

part 'account_event.dart';
part 'account_state.dart';

@injectable
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetProfileUsecase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final ChangeLanguageUseCase _changeLanguage;
  final DeleteAccountUseCase _deleteAccount;
  final CancelAccountDeletionUseCase _cancelDeletion;
  final ExportDataUseCase _exportData;
  final SubscriptionsBloc _subscriptionsBloc;
  final AuthBloc _authBloc;

  AccountBloc(
    this._getProfile,
    this._updateProfile,
    this._changeLanguage,
    this._deleteAccount,
    this._cancelDeletion,
    this._exportData,
    this._subscriptionsBloc,
    this._authBloc,
  ) : super(const AccountState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<CancelAccountDeletionEvent>(_onCancelDeletion);
    on<ExportDataEvent>(_onExportData);
    on<ClearErrorEvent>((event, emit) {
      emit(
        state.copyWith(
          status: AccountStatus.initial,
          clearError: true,
          clearSuccess: true,
        ),
      );
    });
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.loading, clearError: true));
    final result = await _getProfile(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AccountStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (profile) {
        // RC init is keyed on the auth user's id, not on the health profile.
        if (_subscriptionsBloc.state.status == SubscriptionStatus.initial) {
          final userId = _authBloc.state.user?.id;
          if (userId != null && userId.isNotEmpty) {
            debugPrint('RC init from AccountBloc with user id: $userId');
            _subscriptionsBloc.add(InitializeRC(userId));
          }
        }
        emit(state.copyWith(status: AccountStatus.loaded, profile: profile));
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.updating, clearError: true));
    final result = await _updateProfile(event.updatedData);
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AccountStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: AccountStatus.updated,
          profile: profile,
          successMessage: 'Profile updated',
        ),
      ),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.deleting, clearError: true));
    final result = await _deleteAccount(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AccountStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (_) => emit(state.copyWith(status: AccountStatus.deleted)),
    );
  }

  Future<void> _onCancelDeletion(
    CancelAccountDeletionEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.cancelling, clearError: true));
    final result = await _cancelDeletion(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AccountStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: AccountStatus.loaded,
          successMessage: 'Deletion cancelled',
        ),
      ),
    );
  }

  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.exporting, clearError: true));
    final result = await _exportData(NoParams());
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AccountStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: AccountStatus.loaded,
          successMessage: 'Export requested — check your email',
        ),
      ),
    );
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<AccountState> emit,
  ) async {
    final result = await _changeLanguage(event.langCode);
    result.fold(
      (f) => emit(
        state.copyWith(
          status: AccountStatus.error,
          errorMessage: mapFailure(f),
        ),
      ),
      (_) => emit(state.copyWith(currentLang: event.langCode)),
    );
  }
}
