// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:firebase_database/firebase_database.dart' as _i345;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/repositories/contract_pending_auth_repository.dart'
    as _i115;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/begin_sign_in_usecase.dart'
    as _i339;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/launch/domain/usecases/restore_session_usecase.dart'
    as _i533;
import '../../features/launch/presentation/bloc/launch_bloc.dart' as _i646;
import '../api_client/client/dio_client.dart' as _i758;
import '../api_client/client_provider.dart' as _i546;
import '../config/api_config.dart' as _i51;
import '../storage/storage_preference_manager.dart' as _i934;
import 'module_injector.dart' as _i759;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModules = _$RegisterModules();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModules.prefs(),
      preResolve: true,
    );
    gh.lazySingleton<_i51.ApiConfig>(() => const _i51.ApiConfig());
    gh.lazySingleton<_i533.RestoreSessionUseCase>(
        () => _i533.RestoreSessionUseCase());
    gh.factory<_i892.FirebaseMessaging>(
      () => registerModules.firebaseMessaging,
      instanceName: 'firebaseMessaging',
    );
    gh.factory<_i345.FirebaseDatabase>(
      () => registerModules.firebaseDatabase,
      instanceName: 'firebaseDatabase',
    );
    gh.factory<String>(
      () => registerModules.baseUrl,
      instanceName: 'BaseUrl',
    );
    gh.lazySingleton<_i758.DioClient>(
        () => _i758.DioClient(gh<_i51.ApiConfig>()));
    gh.factory<_i646.LaunchBloc>(
        () => _i646.LaunchBloc(gh<_i533.RestoreSessionUseCase>()));
    gh.lazySingleton<_i787.AuthRepository>(
        () => _i115.ContractPendingAuthRepository());
    gh.lazySingleton<_i934.SharedPreferencesManager>(
        () => _i934.SharedPreferencesManager(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i546.ClientProvider>(
        () => _i546.ClientProvider(gh<_i758.DioClient>()));
    gh.factory<_i339.BeginSignInUseCase>(
        () => _i339.BeginSignInUseCase(gh<_i787.AuthRepository>()));
    gh.lazySingleton<_i361.Dio>(
        () => registerModules.dio(gh<String>(instanceName: 'BaseUrl')));
    gh.factory<_i797.AuthBloc>(
        () => _i797.AuthBloc(gh<_i339.BeginSignInUseCase>()));
    return this;
  }
}

class _$RegisterModules extends _i759.RegisterModules {}
