// lib/core/services/media_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles camera and photo library access.
///
/// iOS:   image_picker shows the native permission dialog itself for photos.
///        We only need permission_handler for camera on first launch.
/// Android: permission_handler manages both camera and storage/photos.
class MediaService {
  final _picker = ImagePicker();

  // ── Gallery ──────────────────────────────────────────────────────────────

  /// Pick multiple images from the photo library.
  /// Let image_picker handle the iOS permission prompt natively —
  /// do NOT pre-gate with permission_handler on iOS (it returns denied
  /// on simulator and breaks the flow).
  Future<List<File>> pickFromGallery({int imageQuality = 85}) async {
    if (Platform.isAndroid) {
      // Android 13+ uses READ_MEDIA_IMAGES, older uses READ_EXTERNAL_STORAGE
      final permission = (await Permission.photos.status).isGranted
          ? Permission.photos
          : Permission.storage;
      final status = await permission.request();
      if (!status.isGranted && !status.isLimited) return [];
    }
    // iOS: image_picker triggers the native permission sheet automatically
    final results = await _picker.pickMultiImage(imageQuality: imageQuality);
    return results.map((x) => File(x.path)).toList();
  }

  // ── Camera ───────────────────────────────────────────────────────────────

  /// Capture a single image from the camera.
  /// Returns null if permission is denied or user cancels.
  Future<File?> pickFromCamera({int imageQuality = 85}) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    final result = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
    return result != null ? File(result.path) : null;
  }

  // ── Settings dialog (mirrors LocationHelper) ─────────────────────────────

  static Future<void> showPermissionDialog(
    BuildContext context, {
    required String permissionName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$permissionName Access Required'),
        content: Text(
          'To attach documents, we need $permissionName access. '
          'Please enable it in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
