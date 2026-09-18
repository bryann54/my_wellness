import 'package:my_wellness/core/errors/failures.dart';

String mapFailure(Failure f) => switch (f) {
      NetworkFailure() => 'Check your internet connection',
      ServerFailure() => 'Server error, please try again',
      ValidationFailure(:final error) => error,
      GeneralFailure(:final error) => error,
      _ => 'An unexpected error occurred',
    };

String mapFailureToMessage(dynamic failure) {
  if (failure is ValidationFailure) return failure.error;
  if (failure is GeneralFailure) return failure.error;
  if (failure is UnauthorizedFailure) return "Invalid email or password";
  if (failure is NetworkFailure) return "Check your internet connection";
  return "An unexpected error occurred";
}

String fmtDate(DateTime d) => '${d.day} ${[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][d.month - 1]} ${d.year}';
