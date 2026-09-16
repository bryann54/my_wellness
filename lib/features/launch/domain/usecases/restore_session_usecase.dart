import 'package:injectable/injectable.dart';

@lazySingleton
class RestoreSessionUseCase {
  /// Persistent session restoration awaits an approved identity/session contract.
  Future<bool> call() async => false;
}
