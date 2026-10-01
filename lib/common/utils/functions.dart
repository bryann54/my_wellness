import 'package:dartz/dartz.dart';
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

String fmtDate(DateTime d) =>
    '${d.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';

extension EitherX<L, R> on Either<L, R> {
  R getOrThrow() => fold((l) => throw Exception('Left: $l'), (r) => r);
  L getLeftOrThrow() => fold((l) => l, (r) => throw Exception('Right: $r'));
}

DateTime? parseDateTime(String dateIso, String timeIso) {
  try {
    final d = DateTime.parse(dateIso);
    final t = timeIso.contains('T')
        ? DateTime.parse(timeIso)
        : _parseTime(timeIso);
    if (t == null) return d;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  } catch (_) {
    return null;
  }
}

DateTime? _parseTime(String s) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?').firstMatch(s.trim());
  if (m == null) return null;
  final h = int.tryParse(m.group(1)!);
  final mi = int.tryParse(m.group(2)!);
  if (h == null || mi == null) return null;
  return DateTime(2000, 1, 1, h, mi);
}

String friendlyDay(DateTime d) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
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
    'Dec',
  ];
  return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
}

String friendlyTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
