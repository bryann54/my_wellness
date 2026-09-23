// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/account/data/datasources/account_local_datasource.dart'
    as _i29;
import '../../features/account/data/datasources/account_remote_datasource.dart'
    as _i302;
import '../../features/account/data/repositories/account_repository_impl.dart'
    as _i857;
import '../../features/account/domain/repositories/account_repository.dart'
    as _i1067;
import '../../features/account/domain/usecases/cancel_account_deletion_usecase.dart'
    as _i1033;
import '../../features/account/domain/usecases/change_language_usecase.dart'
    as _i993;
import '../../features/account/domain/usecases/delete_account_usecase.dart'
    as _i949;
import '../../features/account/domain/usecases/export_data_usecase.dart'
    as _i79;
import '../../features/account/domain/usecases/get_profile_usecase.dart'
    as _i682;
import '../../features/account/domain/usecases/update_profile_usecase.dart'
    as _i23;
import '../../features/account/presentation/bloc/account_bloc.dart' as _i708;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/auth_usecases.dart' as _i46;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/bloc/biometrics/biometrics_bloc.dart'
    as _i347;
import '../../features/geography/data/datasources/geography_remote_datasource.dart'
    as _i474;
import '../../features/geography/data/repositories/geography_repository_impl.dart'
    as _i771;
import '../../features/geography/domain/repositories/geography_repository.dart'
    as _i480;
import '../../features/geography/domain/usecases/get_constituencies_usecase.dart'
    as _i275;
import '../../features/geography/domain/usecases/get_counties_usecase.dart'
    as _i331;
import '../../features/geography/domain/usecases/get_sub_counties_usecase.dart'
    as _i8;
import '../../features/geography/domain/usecases/get_wards_usecase.dart'
    as _i903;
import '../../features/geography/presentation/bloc/geography_bloc.dart'
    as _i137;
import '../../features/subscriptions/data/datasources/rc_subscription_datasource.dart'
    as _i226;
import '../../features/subscriptions/data/repositories/rc_subscription_repository_impl.dart'
    as _i236;
import '../../features/subscriptions/domain/repositories/rc_subscription_repository.dart'
    as _i818;
import '../../features/subscriptions/domain/usecases/rc_get_entitlements_usecase.dart'
    as _i1043;
import '../../features/subscriptions/domain/usecases/rc_get_offerings_usecase.dart'
    as _i874;
import '../../features/subscriptions/domain/usecases/rc_purchase_package_usecase.dart'
    as _i805;
import '../../features/subscriptions/domain/usecases/rc_restore_purchases_usecase.dart'
    as _i163;
import '../../features/subscriptions/presentation/bloc/subscriptions_bloc.dart'
    as _i77;
import '../../features/vitals/data/datasources/vitals_remote_datasource.dart'
    as _i216;
import '../../features/vitals/data/repositories/vitals_repository_impl.dart'
    as _i214;
import '../../features/vitals/domain/repositories/vitals_repository.dart'
    as _i515;
import '../../features/vitals/domain/usecases/vitals_usecases.dart' as _i425;
import '../../features/vitals/presentation/bloc/vitals_bloc.dart' as _i902;
import '../api_client/client/api_client.dart' as _i671;
import '../api_client/interceptors/auth_interceptor.dart' as _i878;
import '../services/biometric_service.dart' as _i374;
import '../services/pin_service.dart' as _i845;
import '../storage/storage_preference_manager.dart' as _i934;
import 'module_injector.dart' as _i759;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModules = _$RegisterModules();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModules.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModules.secureStorage,
    );
    gh.lazySingleton<_i374.BiometricService>(() => _i374.BiometricService());
    gh.lazySingleton<_i845.PinService>(() => _i845.PinService());
    gh.factory<String>(() => registerModules.baseUrl, instanceName: 'BaseUrl');
    gh.factory<String>(
      () => registerModules.rcApiKey,
      instanceName: 'rcApiKey',
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i934.SharedPreferencesManager>(
      () => _i934.SharedPreferencesManager(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i347.BiometricsBloc>(
      () => _i347.BiometricsBloc(
        gh<_i374.BiometricService>(),
        gh<_i845.PinService>(),
      ),
    );
    gh.lazySingleton<_i29.AccountLocalDatasource>(
      () => _i29.AccountLocalDatasource(gh<_i934.SharedPreferencesManager>()),
    );
    gh.lazySingleton<_i878.AuthInterceptor>(
      () => _i878.AuthInterceptor(
        gh<_i992.AuthLocalDataSource>(),
        gh<String>(instanceName: 'BaseUrl'),
      ),
    );
    gh.lazySingleton<_i226.RCSubscriptionDatasource>(
      () => _i226.RCSubscriptionDatasourceImpl(
        gh<String>(instanceName: 'rcApiKey'),
      ),
    );
    gh.lazySingleton<_i671.ApiClient>(
      () => _i671.ApiClient(
        gh<String>(instanceName: 'BaseUrl'),
        gh<_i878.AuthInterceptor>(),
      ),
    );
    gh.lazySingleton<_i474.GeographyRemoteDataSource>(
      () => _i474.GeographyRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i216.VitalsRemoteDataSource>(
      () => _i216.VitalsRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i818.RCSubscriptionRepository>(
      () => _i236.RCSubscriptionRepositoryImpl(
        gh<_i226.RCSubscriptionDatasource>(),
      ),
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i480.GeographyRepository>(
      () =>
          _i771.GeographyRepositoryImpl(gh<_i474.GeographyRemoteDataSource>()),
    );
    gh.lazySingleton<_i302.AccountRemoteDataSource>(
      () => _i302.AccountRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i161.AuthRemoteDataSource>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i1067.AccountRepository>(
      () => _i857.AccountRepositoryImpl(
        gh<_i302.AccountRemoteDataSource>(),
        gh<_i29.AccountLocalDatasource>(),
      ),
    );
    gh.factory<_i1043.RCGetEntitlementsUseCase>(
      () =>
          _i1043.RCGetEntitlementsUseCase(gh<_i818.RCSubscriptionRepository>()),
    );
    gh.factory<_i874.RCGetOfferingsUseCase>(
      () => _i874.RCGetOfferingsUseCase(gh<_i818.RCSubscriptionRepository>()),
    );
    gh.factory<_i805.RCPurchasePackageUseCase>(
      () =>
          _i805.RCPurchasePackageUseCase(gh<_i818.RCSubscriptionRepository>()),
    );
    gh.factory<_i163.RCRestorePurchasesUseCase>(
      () =>
          _i163.RCRestorePurchasesUseCase(gh<_i818.RCSubscriptionRepository>()),
    );
    gh.lazySingleton<_i515.VitalsRepository>(
      () => _i214.VitalsRepositoryImpl(gh<_i216.VitalsRemoteDataSource>()),
    );
    gh.lazySingleton<_i275.GetConstituenciesUseCase>(
      () => _i275.GetConstituenciesUseCase(gh<_i480.GeographyRepository>()),
    );
    gh.lazySingleton<_i331.GetCountiesUseCase>(
      () => _i331.GetCountiesUseCase(gh<_i480.GeographyRepository>()),
    );
    gh.lazySingleton<_i8.GetSubCountiesUseCase>(
      () => _i8.GetSubCountiesUseCase(gh<_i480.GeographyRepository>()),
    );
    gh.lazySingleton<_i903.GetWardsUseCase>(
      () => _i903.GetWardsUseCase(gh<_i480.GeographyRepository>()),
    );
    gh.lazySingleton<_i46.SignInUseCase>(
      () => _i46.SignInUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.SignUpUseCase>(
      () => _i46.SignUpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.ConfirmSignupEmailUseCase>(
      () => _i46.ConfirmSignupEmailUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.ConfirmSignupPhoneUseCase>(
      () => _i46.ConfirmSignupPhoneUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.ResendSignupEmailUseCase>(
      () => _i46.ResendSignupEmailUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.ResendSignupPhoneUseCase>(
      () => _i46.ResendSignupPhoneUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.SignOutUseCase>(
      () => _i46.SignOutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.GetAuthStateUseCase>(
      () => _i46.GetAuthStateUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.RequestPasswordResetUseCase>(
      () => _i46.RequestPasswordResetUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.ConfirmPasswordResetUseCase>(
      () => _i46.ConfirmPasswordResetUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.GetCurrentUserUseCase>(
      () => _i46.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i993.ChangeLanguageUseCase>(
      () => _i993.ChangeLanguageUseCase(gh<_i1067.AccountRepository>()),
    );
    gh.lazySingleton<_i682.GetProfileUsecase>(
      () => _i682.GetProfileUsecase(gh<_i1067.AccountRepository>()),
    );
    gh.factory<_i1033.CancelAccountDeletionUseCase>(
      () => _i1033.CancelAccountDeletionUseCase(gh<_i1067.AccountRepository>()),
    );
    gh.factory<_i949.DeleteAccountUseCase>(
      () => _i949.DeleteAccountUseCase(gh<_i1067.AccountRepository>()),
    );
    gh.factory<_i79.ExportDataUseCase>(
      () => _i79.ExportDataUseCase(gh<_i1067.AccountRepository>()),
    );
    gh.factory<_i23.UpdateProfileUseCase>(
      () => _i23.UpdateProfileUseCase(gh<_i1067.AccountRepository>()),
    );
    gh.lazySingleton<_i425.GetAppointmentsByConditionUseCase>(
      () =>
          _i425.GetAppointmentsByConditionUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.GetAppointmentsPagedUseCase>(
      () => _i425.GetAppointmentsPagedUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.CreateAppointmentUseCase>(
      () => _i425.CreateAppointmentUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.DeleteAppointmentUseCase>(
      () => _i425.DeleteAppointmentUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.GetMedicationsByConditionUseCase>(
      () =>
          _i425.GetMedicationsByConditionUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.GetMedicationsPagedUseCase>(
      () => _i425.GetMedicationsPagedUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.CreateMedicationUseCase>(
      () => _i425.CreateMedicationUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.DeleteMedicationUseCase>(
      () => _i425.DeleteMedicationUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.GetBloodPressureReadingsUseCase>(
      () => _i425.GetBloodPressureReadingsUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.CreateBloodPressureReadingUseCase>(
      () =>
          _i425.CreateBloodPressureReadingUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.DeleteBloodPressureReadingUseCase>(
      () =>
          _i425.DeleteBloodPressureReadingUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.GetBloodSugarReadingsUseCase>(
      () => _i425.GetBloodSugarReadingsUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.CreateBloodSugarReadingUseCase>(
      () => _i425.CreateBloodSugarReadingUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.DeleteBloodSugarReadingUseCase>(
      () => _i425.DeleteBloodSugarReadingUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.factory<_i137.GeographyBloc>(
      () => _i137.GeographyBloc(
        gh<_i331.GetCountiesUseCase>(),
        gh<_i8.GetSubCountiesUseCase>(),
        gh<_i275.GetConstituenciesUseCase>(),
        gh<_i903.GetWardsUseCase>(),
      ),
    );
    gh.factory<_i902.VitalsBloc>(
      () => _i902.VitalsBloc(
        gh<_i425.GetAppointmentsPagedUseCase>(),
        gh<_i425.GetMedicationsPagedUseCase>(),
        gh<_i425.GetBloodPressureReadingsUseCase>(),
        gh<_i425.GetBloodSugarReadingsUseCase>(),
        gh<_i425.CreateBloodPressureReadingUseCase>(),
        gh<_i425.CreateBloodSugarReadingUseCase>(),
        gh<_i425.CreateMedicationUseCase>(),
        gh<_i425.CreateAppointmentUseCase>(),
        gh<_i425.DeleteBloodPressureReadingUseCase>(),
        gh<_i425.DeleteBloodSugarReadingUseCase>(),
        gh<_i425.DeleteMedicationUseCase>(),
        gh<_i425.DeleteAppointmentUseCase>(),
      ),
    );
    gh.factory<_i77.SubscriptionsBloc>(
      () => _i77.SubscriptionsBloc(
        gh<_i818.RCSubscriptionRepository>(),
        gh<_i874.RCGetOfferingsUseCase>(),
        gh<_i805.RCPurchasePackageUseCase>(),
        gh<_i163.RCRestorePurchasesUseCase>(),
        gh<_i1043.RCGetEntitlementsUseCase>(),
      ),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        signInUseCase: gh<_i46.SignInUseCase>(),
        signUpUseCase: gh<_i46.SignUpUseCase>(),
        confirmSignupEmailUseCase: gh<_i46.ConfirmSignupEmailUseCase>(),
        confirmSignupPhoneUseCase: gh<_i46.ConfirmSignupPhoneUseCase>(),
        resendSignupEmailUseCase: gh<_i46.ResendSignupEmailUseCase>(),
        resendSignupPhoneUseCase: gh<_i46.ResendSignupPhoneUseCase>(),
        signOutUseCase: gh<_i46.SignOutUseCase>(),
        getAuthStateUseCase: gh<_i46.GetAuthStateUseCase>(),
        requestPasswordResetUseCase: gh<_i46.RequestPasswordResetUseCase>(),
        confirmPasswordResetUseCase: gh<_i46.ConfirmPasswordResetUseCase>(),
        subscriptionsBloc: gh<_i77.SubscriptionsBloc>(),
      ),
    );
    gh.factory<_i708.AccountBloc>(
      () => _i708.AccountBloc(
        gh<_i682.GetProfileUsecase>(),
        gh<_i23.UpdateProfileUseCase>(),
        gh<_i993.ChangeLanguageUseCase>(),
        gh<_i949.DeleteAccountUseCase>(),
        gh<_i1033.CancelAccountDeletionUseCase>(),
        gh<_i79.ExportDataUseCase>(),
        gh<_i77.SubscriptionsBloc>(),
        gh<_i797.AuthBloc>(),
      ),
    );
    return this;
  }
}

class _$RegisterModules extends _i759.RegisterModules {}
