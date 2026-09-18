// lib/common/utils/map_utils.dart
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  static Future<void> openMap({
    required double lat,
    required double lng,
    required String title,
  }) async {
    final coords = Coords(lat, lng);

    try {
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isNotEmpty) {
        await MapLauncher.showMarker(
          mapType: MapType.google,
          coords: coords,
          title: title,
        );
      } else {
        await _launchMapInBrowser(lat, lng);
      }
    } catch (e) {
      await _launchMapInBrowser(lat, lng);
    }
  }

  static Future<void> _launchMapInBrowser(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open map in browser';
    }
  }
}
