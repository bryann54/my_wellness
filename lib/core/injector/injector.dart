import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/injector/injector.config.dart';

final getIt = GetIt.instance;

@InjectableInit(initializerName: 'init', preferRelativeImports: true)
Future<GetIt> configureDependencies() async => getIt.init();
