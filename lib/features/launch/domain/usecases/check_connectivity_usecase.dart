import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';
import 'package:my_wellness/core/errors/failures.dart';

@lazySingleton
class CheckConnectivityUsecase implements UseCase<NoParams, NoParams> {
  CheckConnectivityUsecase();

  @override
  Future<Either<Failure, NoParams>> call(NoParams params) async {
    final connectivity = Connectivity();
    final interfaces = await connectivity.checkConnectivity();
    if (_hasInterface(interfaces)) return const Right(NoParams());

    await Future<void>.delayed(const Duration(milliseconds: 800));
    final retry = await connectivity.checkConnectivity();
    if (_hasInterface(retry)) return const Right(NoParams());

    return const Left(NetworkFailure());
  }

  bool _hasInterface(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn ||
          r == ConnectivityResult.bluetooth ||
          r == ConnectivityResult.other,
    );
  }
}
