import 'package:injectable/injectable.dart';
import 'package:my_wellness/common/handlers/errors/failures.dart';
import 'package:my_wellness/features/auth/domain/repositories/auth_repository.dart';

@injectable
class BeginSignInUseCase {
  const BeginSignInUseCase(this._repository);
  final AuthRepository _repository;
  Future<Failure?> call() => _repository.beginSignIn();
}
