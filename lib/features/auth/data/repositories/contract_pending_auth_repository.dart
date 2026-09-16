import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/handlers/errors/failures.dart';
import 'package:my_wellness/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class ContractPendingAuthRepository implements AuthRepository {
  @override
  Future<Failure?> beginSignIn() async => const ContractUnavailableFailure();
}
