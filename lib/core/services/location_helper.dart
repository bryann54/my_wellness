// lib/core/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationHelper {
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Required'),
        content: const Text(
          'To report an incident accurately, we need your GPS coordinates. '
          'Please enable location permissions in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
