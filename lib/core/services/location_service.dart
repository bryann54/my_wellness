// lib/core/services/location_service.dart

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final String address;
  final double lat;
  final double lng;

  const LocationResult({
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class LocationService {
  Future<LocationResult?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return await _reverseGeocode(pos);
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<LocationResult> _reverseGeocode(Position pos) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          p.street,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        return LocationResult(
          address: address.isNotEmpty ? address : _rawCoords(pos),
          lat: pos.latitude,
          lng: pos.longitude,
        );
      }
    } catch (_) {}

    return LocationResult(
      address: _rawCoords(pos),
      lat: pos.latitude,
      lng: pos.longitude,
    );
  }

  String _rawCoords(Position pos) =>
      '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
}
