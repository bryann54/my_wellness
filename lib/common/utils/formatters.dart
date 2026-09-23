import 'package:intl/intl.dart';

String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

String isoTimestampUtc(DateTime d) => d.toUtc().toIso8601String();
String friendlyDateTime(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return iso;
  return DateFormat('d MMM yyyy · h:mm a').format(dt);
}

String friendlyDate(String iso) {
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return iso;
  return DateFormat('d MMM').format(dt);
}
