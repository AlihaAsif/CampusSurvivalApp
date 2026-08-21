import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';


class ImageStorage {
  ImageStorage._();


  static Future<File> compress(File file) async {
    final directory = await getTemporaryDirectory();
    final target =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      target,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
    );

    return result == null ? file : File(result.path);
  }

  static Future<String> upload({
    required File file,
    required String folder,
  }) async {
    final compressed = await compress(file);

    final fileName =
        '$folder/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final storage =
    Supabase.instance.client.storage.from(SupabaseConfig.lostItemsBucket);

    await storage.upload(
      fileName,
      compressed,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );

    return storage.getPublicUrl(fileName);
  }
}