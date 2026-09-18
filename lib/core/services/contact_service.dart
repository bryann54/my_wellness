// lib/core/services/contact_service.dart
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  static Future<List<Contact>> getContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) return [];
    return FlutterContacts.getContacts(withProperties: true);
  }
}
