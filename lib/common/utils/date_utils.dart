import 'package:intl/intl.dart';

String formatDate(String dateString, {String? format}) {
  DateTime dateTime = DateTime.parse(dateString);
  return DateFormat(format ?? 'yyyy-MM-dd').format(dateTime);
}

String formatDateObj(DateTime date, {String? format}) {
  return DateFormat(format ?? 'yyyy-MM-dd').format(date);
}

DateTime getCurrentDateTime() => DateTime.now();

DateTime addDays(int days, DateTime date) {
  return date.add(Duration(days: days));
}

String timeAgo(String dateString) {
  final date = DateTime.parse(dateString).toLocal();
  final diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h ${h == 1 ? 'hour' : 'hours'} ago';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return '$d ${d == 1 ? 'day' : 'days'} ago';
  }
  if (diff.inDays < 30) {
    final w = (diff.inDays / 7).floor();
    return '$w ${w == 1 ? 'week' : 'weeks'} ago';
  }
  if (diff.inDays < 365) {
    final mo = (diff.inDays / 30).floor();
    return '$mo ${mo == 1 ? 'month' : 'months'} ago';
  }
  final y = (diff.inDays / 365).floor();
  return '$y ${y == 1 ? 'year' : 'years'} ago';
}
