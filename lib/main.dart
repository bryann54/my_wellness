import 'package:my_wellness/common/helpers/app_router.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/notifiers/theme_provider.dart';
import 'package:my_wellness/common/res/app_theme.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/global_bloc_observer.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:my_wellness/features/app_lock/presentation/widgets/app_lock_gate.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_event.dart';
import 'package:my_wellness/features/auth/presentation/bloc/auth_state.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:my_wellness/features/geography/presentation/bloc/geography_bloc.dart';
import 'package:my_wellness/features/home/presentation/bloc/home_bloc.dart';
import 'package:my_wellness/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:my_wellness/features/medications/presentation/bloc/medications_bloc.dart';
import 'package:my_wellness/features/notifications/data/notification_service.dart';
import 'package:my_wellness/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:my_wellness/features/notifications/presentation/notification_host.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_capture_bloc.dart';
import 'package:my_wellness/features/wellness/presentation/bloc/wellness_bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    await dotenv.load(fileName: 'env/.env');
  } else {
    Bloc.observer = AppGlobalBlocObserver();
    await dotenv.load(fileName: 'env/.dev.env');
  }

  await _configureGoogleMaps();
  await configureDependencies();
  await PackageInfo.fromPlatform();

  await getIt<NotificationService>().initialize();

  final localeProvider = LocaleProvider()..loadLocale();
  final themeProvider = ThemeProvider()..load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(
          create: (_) => getIt<AccountBloc>()..add(FetchProfileEvent()),
        ),
        BlocProvider(create: (_) => getIt<AppLockBloc>()),
        BlocProvider(create: (_) => getIt<HomeBloc>()),
        BlocProvider(create: (_) => getIt<AssessmentsBloc>()),
        BlocProvider(create: (_) => getIt<BookingsBloc>()),
        BlocProvider(create: (_) => getIt<WellnessBloc>()),
        BlocProvider(create: (_) => getIt<GeographyBloc>()),
        BlocProvider(create: (_) => getIt<LaunchBloc>()),
        BlocProvider(create: (_) => getIt<VitalsCaptureBloc>()),
        BlocProvider(create: (_) => getIt<VitalsBloc>()),
        BlocProvider(create: (_) => getIt<MedicationsBloc>()),
        BlocProvider(create: (_) => getIt<NotificationsBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _configureGoogleMaps() async {
  if (defaultTargetPlatform != TargetPlatform.iOS) return;

  const platform = MethodChannel('com.legaldefender/maps');

  try {
    await platform.invokeMethod('setApiKey', {
      'apiKey': dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? '',
    });
  } on PlatformException catch (e) {
    debugPrint('Failed to set Google Maps API key: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final _appRouter = AppRouter();

  @override
  void dispose() {
    getIt<NotificationService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final themeMode = context.watch<ThemeProvider>().mode;

    // Status-bar icons must contrast with the currently active surface.
    final brightness = switch (themeMode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => MediaQuery.of(context).platformBrightness,
    };
    final overlay = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: MaterialApp.router(
        title: AppLocalizations.getString(context, 'appName'),
        debugShowCheckedModeBanner: false,
        routerConfig: _appRouter.config(),
        builder: (context, child) {
          if (child == null) return const SizedBox.shrink();
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status &&
                curr.status == AuthStatus.unauthenticated,
            listener: (context, _) =>
                context.read<AppLockBloc>().add(const AppLockReset()),
            child: AppLockGate(
              onLogout: () =>
                  context.read<AuthBloc>().add(const SignOutEvent()),
              child: NotificationHost(child: child),
            ),
          );
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('sw')],
        locale: locale,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
      ),
    );
  }
}
