// lib/main.dart

import 'package:my_wellness/common/widgets/global_error_listener.dart';
import 'package:my_wellness/features/account/presentation/bloc/account_bloc.dart';
import 'package:my_wellness/features/assessments/presentation/bloc/assessments_bloc.dart';
import 'package:my_wellness/features/auth/presentation/bloc/biometrics/biometrics_bloc.dart';
import 'package:my_wellness/features/bookings/presentation/bloc/bookings_bloc.dart';

import 'package:my_wellness/features/home/presentation/bloc/home_bloc.dart';
import 'package:my_wellness/common/helpers/app_router.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/notifiers/locale_provider.dart';
import 'package:my_wellness/common/widgets/global_bloc_observer.dart';
import 'package:my_wellness/core/di/injector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_wellness/features/medications/presentation/bloc/medications_bloc.dart';
import 'package:my_wellness/features/subscriptions/presentation/bloc/subscriptions_bloc.dart';
import 'package:my_wellness/features/vitals/presentation/bloc/vitals_bloc.dart';
import 'package:my_wellness/features/wellness/presentation/bloc/wellness_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:my_wellness/features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    await dotenv.load(fileName: "env/.env");
  } else {
    Bloc.observer = AppGlobalBlocObserver();
    await dotenv.load(fileName: "env/.dev.env");
  }
  await _configureGoogleMaps();
  await configureDependencies();
  await PackageInfo.fromPlatform();
  final localeProvider = LocaleProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => localeProvider),
        BlocProvider(create: (context) => getIt<SubscriptionsBloc>()),
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<AccountBloc>()),
        BlocProvider(create: (context) => getIt<BiometricsBloc>()),
        BlocProvider(create: (context) => getIt<HomeBloc>()),
        BlocProvider(create: (context) => getIt<AssessmentsBloc>()),
        BlocProvider(create: (context) => getIt<BookingsBloc>()),
        BlocProvider(create: (context) => getIt<WellnessBloc>()),
        BlocProvider(
          create: (_) => getIt<VitalsBloc>()..add(const LoadVitalsEvent()),
        ),
        BlocProvider(create: (context) => getIt<MedicationsBloc>()),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> _configureGoogleMaps() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    const platform = MethodChannel('com.legaldefender/maps');
    try {
      await platform.invokeMethod('setApiKey', {
        'apiKey': dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? '',
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to set Google Maps API key: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final systemUiOverlayStyle =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    final localeProvider = Provider.of<LocaleProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: !kReleaseMode,
        title: AppLocalizations.getString(context, 'appName'),
        routerConfig: _appRouter.config(),
        builder: (context, child) {
          return Builder(
            builder: (childContext) {
              return GlobalErrorListener(child: child!);
            },
          );
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('sw')],
        locale: localeProvider.locale,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[500],
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
