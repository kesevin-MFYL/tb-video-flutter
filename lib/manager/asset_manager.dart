import 'dart:async';
import 'package:editvideo/config/log/logger.dart';
import 'package:image_picker/image_picker.dart';

class AssetManager {
  static final instance = AssetManager._();

  AssetManager._();

  final ImagePicker picker = ImagePicker();

  Future<XFile?> pickVideos() async {
    try {
      final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
      return file;
    } catch (e) {
      commonDebugPrint('pickVideo error: $e');
      return null;
    }
  }
}
