import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_wellness/common/res/app_theme.dart';
import 'package:my_wellness/common/constatnts/routes.dart';
import 'package:my_wellness/core/injector/injector.dart';
import 'package:my_wellness/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: kReleaseMode ? "env/.env" : "env/.dev.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(const MyWellnessApp());
}

class MyWellnessApp extends StatelessWidget {
  const MyWellnessApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'My Wellness',
        theme: myWellnessTheme(),
        navigatorKey: AppRoutes.navigatorKey,
        initialRoute: AppRoutes.launch,
        onGenerateRoute: AppRoutes.generateRoute,
      );
}
