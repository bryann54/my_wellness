// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
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
import '../../features/app_lock/data/datasources/app_lock_datasource.dart'
    as _i101;
import '../../features/app_lock/data/repositories/app_lock_repository_impl.dart'
    as _i731;
import '../../features/app_lock/domain/repositories/app_lock_repository.dart'
    as _i98;
import '../../features/app_lock/domain/usecases/app_lock_usecases.dart'
    as _i1045;
import '../../features/app_lock/presentation/bloc/app_lock_bloc.dart' as _i766;
import '../../features/appointments/presentation/bloc/appointments_bloc.dart'
    as _i767;
import '../../features/assessments/data/datasources/assessments_remote_datasource.dart'
    as _i470;
import '../../features/assessments/data/repositories/assessments_repository_impl.dart'
    as _i958;
import '../../features/assessments/domain/repositories/assessments_repository.dart'
    as _i544;
import '../../features/assessments/domain/usecases/assessments_usecases.dart'
    as _i6;
import '../../features/assessments/presentation/bloc/assessments_bloc.dart'
    as _i1022;
import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/auth_usecases.dart' as _i46;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
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
import '../../features/home/data/datasources/home_dashboard_remote_datasource.dart'
    as _i219;
import '../../features/home/data/repositories/home_dashboard_repository_impl.dart'
    as _i730;
import '../../features/home/domain/repositories/home_dashboard_repository.dart'
    as _i636;
import '../../features/home/domain/usecases/get_home_dashboard.dart' as _i493;
import '../../features/home/presentation/bloc/home_bloc.dart' as _i202;
import '../../features/launch/domain/usecases/check_connectivity_usecase.dart'
    as _i656;
import '../../features/launch/presentation/bloc/launch_bloc.dart' as _i646;
import '../../features/medications/presentation/bloc/medications_bloc.dart'
    as _i734;
import '../../features/notifications/data/notification_service.dart' as _i597;
import '../../features/notifications/presentation/bloc/notifications_bloc.dart'
    as _i1041;
import '../../features/offline_sync/data/datasources/sync_local_datasource.dart'
    as _i997;
import '../../features/offline_sync/data/local/app_database.dart' as _i669;
import '../../features/offline_sync/data/repositories/sync_repository_impl.dart'
    as _i353;
import '../../features/offline_sync/domain/repositories/sync_repository.dart'
    as _i441;
import '../../features/offline_sync/presentation/bloc/sync_bloc.dart' as _i30;
import '../../features/vitals/data/datasources/vitals_capture_remote_datasource.dart'
    as _i941;
import '../../features/vitals/data/datasources/vitals_remote_datasource.dart'
    as _i216;
import '../../features/vitals/data/repositories/vitals_capture_repository_impl.dart'
    as _i725;
import '../../features/vitals/data/repositories/vitals_repository_impl.dart'
    as _i214;
import '../../features/vitals/domain/repositories/vitals_capture_repository.dart'
    as _i1013;
import '../../features/vitals/domain/repositories/vitals_repository.dart'
    as _i515;
import '../../features/vitals/domain/usecases/vitals_capture_usecases.dart'
    as _i178;
import '../../features/vitals/domain/usecases/vitals_usecases.dart' as _i425;
import '../../features/vitals/presentation/bloc/vitals_bloc.dart' as _i902;
import '../../features/vitals/presentation/bloc/vitals_capture_bloc.dart'
    as _i863;
import '../api_client/client/api_client.dart' as _i671;
import '../api_client/interceptors/auth_interceptor.dart' as _i878;
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
    gh.lazySingleton<_i597.NotificationService>(
      () => registerModules.notificationService,
    );
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => registerModules.localAuthentication,
    );
    gh.lazySingleton<_i669.AppDatabase>(() => registerModules.appDatabase);
    gh.lazySingleton<_i895.Connectivity>(() => registerModules.connectivity);
    gh.lazySingleton<_i656.CheckConnectivityUsecase>(
      () => _i656.CheckConnectivityUsecase(),
    );
    gh.factory<String>(() => registerModules.baseUrl, instanceName: 'BaseUrl');
    gh.lazySingleton<_i101.AppLockDataSource>(
      () => _i101.AppLockDataSourceImpl(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i152.LocalAuthentication>(),
      ),
    );
    gh.factory<_i1041.NotificationsBloc>(
      () => _i1041.NotificationsBloc(gh<_i597.NotificationService>()),
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i997.SyncLocalDataSource>(
      () => _i997.SyncLocalDataSource(gh<_i669.AppDatabase>()),
    );
    gh.lazySingleton<_i98.AppLockRepository>(
      () => _i731.AppLockRepositoryImpl(gh<_i101.AppLockDataSource>()),
    );
    gh.lazySingleton<_i878.AuthInterceptor>(
      () => _i878.AuthInterceptor(
        gh<_i992.AuthLocalDataSource>(),
        gh<String>(instanceName: 'BaseUrl'),
      ),
    );
    gh.lazySingleton<_i934.SharedPreferencesManager>(
      () => _i934.SharedPreferencesManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i1045.GetAppLockStatusUseCase>(
      () => _i1045.GetAppLockStatusUseCase(gh<_i98.AppLockRepository>()),
    );
    gh.lazySingleton<_i1045.AuthenticateAppLockUseCase>(
      () => _i1045.AuthenticateAppLockUseCase(gh<_i98.AppLockRepository>()),
    );
    gh.lazySingleton<_i1045.SetAppLockEnabledUseCase>(
      () => _i1045.SetAppLockEnabledUseCase(gh<_i98.AppLockRepository>()),
    );
    gh.lazySingleton<_i1045.MarkAppLockPromptedUseCase>(
      () => _i1045.MarkAppLockPromptedUseCase(gh<_i98.AppLockRepository>()),
    );
    gh.lazySingleton<_i1045.ClearAppLockUseCase>(
      () => _i1045.ClearAppLockUseCase(gh<_i98.AppLockRepository>()),
    );
    gh.lazySingleton<_i671.ApiClient>(
      () => _i671.ApiClient(
        gh<String>(instanceName: 'BaseUrl'),
        gh<_i878.AuthInterceptor>(),
      ),
    );
    gh.factory<_i766.AppLockBloc>(
      () => _i766.AppLockBloc(
        getStatus: gh<_i1045.GetAppLockStatusUseCase>(),
        authenticate: gh<_i1045.AuthenticateAppLockUseCase>(),
        setEnabled: gh<_i1045.SetAppLockEnabledUseCase>(),
        markPrompted: gh<_i1045.MarkAppLockPromptedUseCase>(),
        clear: gh<_i1045.ClearAppLockUseCase>(),
      ),
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i29.AccountLocalDatasource>(
      () => _i29.AccountLocalDatasource(gh<_i934.SharedPreferencesManager>()),
    );
    gh.lazySingleton<_i216.VitalsRemoteDataSource>(
      () => _i216.VitalsRemoteDataSourceImpl(
        gh<_i671.ApiClient>(),
        gh<_i669.AppDatabase>(),
      ),
    );
    gh.lazySingleton<_i302.AccountRemoteDataSource>(
      () => _i302.AccountRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i219.HomeDashboardRemoteDataSource>(
      () => _i219.HomeDashboardRemoteDataSourceImpl(
        gh<_i671.ApiClient>(),
        gh<_i669.AppDatabase>(),
      ),
    );
    gh.lazySingleton<_i941.VitalsCaptureRemoteDataSource>(
      () => _i941.VitalsCaptureRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i441.SyncRepository>(
      () => _i353.SyncRepositoryImpl(
        gh<_i997.SyncLocalDataSource>(),
        gh<_i671.ApiClient>(),
      ),
    );
    gh.lazySingleton<_i515.VitalsRepository>(
      () => _i214.VitalsRepositoryImpl(
        gh<_i216.VitalsRemoteDataSource>(),
        gh<_i441.SyncRepository>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i161.AuthRemoteDataSource>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
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
    gh.lazySingleton<_i425.ScanMedicationUseCase>(
      () => _i425.ScanMedicationUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.GetMedicationsByConditionUseCase>(
      () =>
          _i425.GetMedicationsByConditionUseCase(gh<_i515.VitalsRepository>()),
    );
    gh.lazySingleton<_i425.SearchFacilitiesUseCase>(
      () => _i425.SearchFacilitiesUseCase(gh<_i515.VitalsRepository>()),
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
    gh.lazySingleton<_i1067.AccountRepository>(
      () => _i857.AccountRepositoryImpl(
        gh<_i302.AccountRemoteDataSource>(),
        gh<_i29.AccountLocalDatasource>(),
      ),
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
    gh.lazySingleton<_i993.ChangeLanguageUseCase>(
      () => _i993.ChangeLanguageUseCase(gh<_i1067.AccountRepository>()),
    );
    gh.lazySingleton<_i682.GetProfileUsecase>(
      () => _i682.GetProfileUsecase(gh<_i1067.AccountRepository>()),
    );
    gh.lazySingleton<_i1013.VitalsCaptureRepository>(
      () => _i725.VitalsCaptureRepositoryImpl(
        gh<_i941.VitalsCaptureRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i474.GeographyRemoteDataSource>(
      () => _i474.GeographyRemoteDataSourceImpl(gh<_i671.ApiClient>()),
    );
    gh.lazySingleton<_i470.AssessmentsRemoteDataSource>(
      () => _i470.AssessmentsRemoteDataSourceImpl(
        gh<_i671.ApiClient>(),
        gh<_i669.AppDatabase>(),
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
      ),
    );
    gh.lazySingleton<_i46.SignInUseCase>(
      () => _i46.SignInUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.SignUpUseCase>(
      () => _i46.SignUpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.VerifyIdentityUseCase>(
      () => _i46.VerifyIdentityUseCase(gh<_i787.AuthRepository>()),
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
    gh.lazySingleton<_i46.RequestPasswordResetUseCase>(
      () => _i46.RequestPasswordResetUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.ConfirmPasswordResetUseCase>(
      () => _i46.ConfirmPasswordResetUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i46.GetCurrentUserUseCase>(
      () => _i46.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i30.SyncBloc>(
      () => _i30.SyncBloc(gh<_i441.SyncRepository>(), gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i636.HomeDashboardRepository>(
      () => _i730.HomeDashboardRepositoryImpl(
        gh<_i219.HomeDashboardRemoteDataSource>(),
      ),
    );
    gh.factory<_i902.VitalsBloc>(
      () => _i902.VitalsBloc(
        gh<_i425.GetBloodPressureReadingsUseCase>(),
        gh<_i425.GetBloodSugarReadingsUseCase>(),
        gh<_i425.CreateBloodPressureReadingUseCase>(),
        gh<_i425.CreateBloodSugarReadingUseCase>(),
        gh<_i425.DeleteBloodPressureReadingUseCase>(),
        gh<_i425.DeleteBloodSugarReadingUseCase>(),
      ),
    );
    gh.factory<_i767.AppointmentsBloc>(
      () => _i767.AppointmentsBloc(
        gh<_i425.GetAppointmentsPagedUseCase>(),
        gh<_i425.CreateAppointmentUseCase>(),
        gh<_i425.DeleteAppointmentUseCase>(),
      ),
    );
    gh.lazySingleton<_i178.GetVitalsCaptureContentUseCase>(
      () => _i178.GetVitalsCaptureContentUseCase(
        gh<_i1013.VitalsCaptureRepository>(),
      ),
    );
    gh.lazySingleton<_i178.CreateVitalsSessionUseCase>(
      () => _i178.CreateVitalsSessionUseCase(
        gh<_i1013.VitalsCaptureRepository>(),
      ),
    );
    gh.lazySingleton<_i178.GetVitalsReferralUseCase>(
      () =>
          _i178.GetVitalsReferralUseCase(gh<_i1013.VitalsCaptureRepository>()),
    );
    gh.factory<_i863.VitalsCaptureBloc>(
      () => _i863.VitalsCaptureBloc(
        gh<_i178.GetVitalsCaptureContentUseCase>(),
        gh<_i178.CreateVitalsSessionUseCase>(),
        gh<_i178.GetVitalsReferralUseCase>(),
      ),
    );
    gh.lazySingleton<_i480.GeographyRepository>(
      () =>
          _i771.GeographyRepositoryImpl(gh<_i474.GeographyRemoteDataSource>()),
    );
    gh.lazySingleton<_i544.AssessmentsRepository>(
      () => _i958.AssessmentRepositoryImpl(
        gh<_i470.AssessmentsRemoteDataSource>(),
        gh<_i441.SyncRepository>(),
      ),
    );
    gh.factory<_i734.MedicationsBloc>(
      () => _i734.MedicationsBloc(
        gh<_i425.GetMedicationsPagedUseCase>(),
        gh<_i425.CreateMedicationUseCase>(),
        gh<_i425.DeleteMedicationUseCase>(),
        gh<_i425.ScanMedicationUseCase>(),
      ),
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
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        signInUseCase: gh<_i46.SignInUseCase>(),
        signUpUseCase: gh<_i46.SignUpUseCase>(),
        confirmSignupEmailUseCase: gh<_i46.ConfirmSignupEmailUseCase>(),
        confirmSignupPhoneUseCase: gh<_i46.ConfirmSignupPhoneUseCase>(),
        resendSignupEmailUseCase: gh<_i46.ResendSignupEmailUseCase>(),
        resendSignupPhoneUseCase: gh<_i46.ResendSignupPhoneUseCase>(),
        signOutUseCase: gh<_i46.SignOutUseCase>(),
        requestPasswordResetUseCase: gh<_i46.RequestPasswordResetUseCase>(),
        confirmPasswordResetUseCase: gh<_i46.ConfirmPasswordResetUseCase>(),
        verifyIdentityUseCase: gh<_i46.VerifyIdentityUseCase>(),
      ),
    );
    gh.factory<_i137.GeographyBloc>(
      () => _i137.GeographyBloc(
        gh<_i331.GetCountiesUseCase>(),
        gh<_i8.GetSubCountiesUseCase>(),
        gh<_i275.GetConstituenciesUseCase>(),
        gh<_i903.GetWardsUseCase>(),
      ),
    );
    gh.factory<_i646.LaunchBloc>(
      () => _i646.LaunchBloc(
        gh<_i656.CheckConnectivityUsecase>(),
        gh<_i46.GetCurrentUserUseCase>(),
      ),
    );
    gh.lazySingleton<_i493.GetHomeDashboardUseCase>(
      () => _i493.GetHomeDashboardUseCase(gh<_i636.HomeDashboardRepository>()),
    );
    gh.factory<_i202.HomeBloc>(
      () => _i202.HomeBloc(gh<_i493.GetHomeDashboardUseCase>()),
    );
    gh.lazySingleton<_i6.GetVitalsAccessUseCase>(
      () => _i6.GetVitalsAccessUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.ListAssessmentsUseCase>(
      () => _i6.ListAssessmentsUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.CanStartAssessmentUseCase>(
      () => _i6.CanStartAssessmentUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.GetAssessmentDefinitionUseCase>(
      () =>
          _i6.GetAssessmentDefinitionUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.StartAssessmentSessionUseCase>(
      () =>
          _i6.StartAssessmentSessionUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.GetReferralForSessionUseCase>(
      () => _i6.GetReferralForSessionUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.GetAssessmentAnswersUseCase>(
      () => _i6.GetAssessmentAnswersUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.SubmitAssessmentAnswerUseCase>(
      () =>
          _i6.SubmitAssessmentAnswerUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.GetAssessmentScoreUseCase>(
      () => _i6.GetAssessmentScoreUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.lazySingleton<_i6.PreviewBmiUseCase>(
      () => _i6.PreviewBmiUseCase(gh<_i544.AssessmentsRepository>()),
    );
    gh.factory<_i1022.AssessmentsBloc>(
      () => _i1022.AssessmentsBloc(
        gh<_i6.GetVitalsAccessUseCase>(),
        gh<_i6.ListAssessmentsUseCase>(),
        gh<_i6.CanStartAssessmentUseCase>(),
        gh<_i6.GetAssessmentDefinitionUseCase>(),
        gh<_i6.StartAssessmentSessionUseCase>(),
        gh<_i6.GetAssessmentAnswersUseCase>(),
        gh<_i6.SubmitAssessmentAnswerUseCase>(),
        gh<_i6.GetReferralForSessionUseCase>(),
        gh<_i6.GetAssessmentScoreUseCase>(),
        gh<_i6.PreviewBmiUseCase>(),
        gh<_i23.UpdateProfileUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModules extends _i759.RegisterModules {}
