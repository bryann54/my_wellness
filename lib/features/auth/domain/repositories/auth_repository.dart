import 'package:my_wellness/common/handlers/errors/failures.dart';

abstract interface class AuthRepository {
  Future<Failure?> beginSignIn();
}
