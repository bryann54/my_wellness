// lib/core/services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';

class LocationHelper {
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.getString(
            context,
            'permissions.locationAccessRequired',
          ),
        ),
        content: Text(
          AppLocalizations.getString(
            context,
            'permissions.locationExplanation',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.getString(context, 'common.cancel'),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: Text(
              AppLocalizations.getString(context, 'permissions.openSettings'),
            ),
          ),
        ],
      ),
    );
  }
}
