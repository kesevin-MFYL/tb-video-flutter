import 'dart:async';
import 'package:editvideo/config/log/logger.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AssetManager {
  static final instance = AssetManager._();

  AssetManager._();

  Future<AssetEntity?> pickVideos() async {
    try {
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(maxAssets: 1, requestType: RequestType.video),
      );

      return result != null && result.isNotEmpty ? result.first : null;
    } catch (e) {
      commonDebugPrint('pickVideo error: $e');
      return null;
    }
  }
}
