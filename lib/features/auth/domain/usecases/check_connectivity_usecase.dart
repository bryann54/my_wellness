import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:my_wellness/core/errors/failures.dart';
import 'package:my_wellness/common/helpers/base_usecase.dart';

@lazySingleton
class CheckConnectivityUsecase implements UseCase<NoParams, NoParams> {
  @override
  Future<Either<Failure, NoParams>> call(NoParams params) async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return Left(NetworkFailure());
    }
    return const Right(NoParams());
  }
}
