// lib/common/helpers/image_compression_helper.dart

import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageCompressionHelper {
  /// Max dimension (width or height) in pixel
  static const int _maxDimension = 1280;
  static const int _targetKb = 800;
  static Future<File> compress(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final ext = p.extension(file.path).toLowerCase();
      final isJpeg = ext == '.jpg' || ext == '.jpeg';
      final outPath =
          '${dir.path}/${p.basenameWithoutExtension(file.path)}_compressed.${isJpeg ? 'jpg' : 'jpg'}';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        outPath,
        quality: 75,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        format: CompressFormat.jpeg,
      );

      if (result == null) return file;

      final compressed = File(result.path);
      final sizeKb = await compressed.length() ~/ 1024;
      if (sizeKb > _targetKb) {
        final outPath2 =
            '${dir.path}/${p.basenameWithoutExtension(file.path)}_compressed2.jpg';
        final result2 = await FlutterImageCompress.compressAndGetFile(
          compressed.path,
          outPath2,
          quality: 50,
          minWidth: 800,
          minHeight: 800,
          format: CompressFormat.jpeg,
        );
        if (result2 != null) return File(result2.path);
      }

      return compressed;
    } catch (_) {
      return file;
    }
  }

  static Future<List<File>> compressAll(List<File> files) async {
    return Future.wait(
      files.map((f) {
        final ext = p.extension(f.path).toLowerCase();
        final isImage = [
          '.jpg',
          '.jpeg',
          '.png',
          '.heic',
          '.heif',
        ].contains(ext);
        return isImage ? compress(f) : Future.value(f);
      }),
    );
  }
}
