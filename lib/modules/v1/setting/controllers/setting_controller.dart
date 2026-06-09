import 'dart:io';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/widget/bottom_sheet/delete_bottom_sheet.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_video_caching/flutter_video_caching.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class SettingController extends BaseController {

  bool isPrivacyOptionsRequired = false;

  var cacheString = ''.obs;

  @override
  void fetchData() {
    getCacheSize();
    //todo GDPR权限检查
    // _checkPrivacyOptionsRequired();
  }

  //todo GDPR权限检查
  // void _checkPrivacyOptionsRequired() async {
  //   isPrivacyOptionsRequired = await ConsentManager.instance.isPrivacyOptionsRequired();
  //   update();
  // }

  //todo GDPR权限检查
  // void showPrivacyOptions() {
  //   ConsentManager.instance.showPrivacyOptionsForm((formError) {
  //     if (formError != null) {
  //       commonDebugPrint('SettingController: Failed to show privacy options form: ${formError.message}');
  //     }
  //     // 重新检查是否还需要显示隐私选项（比如用户改变了主意或删除了所有数据）
  //     _checkPrivacyOptionsRequired();
  //   });
  // }

  getCacheSize() async {
    try {
      int totalSize = 0;

      // 1. 获取视频缓存大小
      totalSize += await LruCacheSingleton().storageSizeInBytes();
      commonDebugPrint('视频缓存大小为：$totalSize bytes');

      // 2. 获取图片缓存大小 (DefaultCacheManager 默认使用的 key 是 libCachedImageData)
      final cacheDir = await getTemporaryDirectory();
      final imageCacheDir = Directory('${cacheDir.path}/libCachedImageData');
      if (await imageCacheDir.exists()) {
        final List<FileSystemEntity> files = imageCacheDir.listSync(recursive: true);
        for (var file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }

      // 将 bytes 转换为 MB 或 GB 等更易读的格式
      if (totalSize < 1024 * 1024) {
        cacheString.value = '${(totalSize / 1024).toStringAsFixed(2)} KB';
      } else if (totalSize < 1024 * 1024 * 1024) {
        cacheString.value = '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
      } else {
        cacheString.value = '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
      }
    } catch (e) {
      commonDebugPrint('Get total cache size error: $e');
      cacheString.value = '0.00 KB';
    }
  }

  void clearCache() async {
    DeleteBottomSheet.show(
      title: 'Cache',
      tips: 'Are you sure you want to delete cached data? It will be permanently removed.',
      imageAsset: Assets.commonIconClearCache,
      onConfirm: () async {
        EasyLoading.show();
        try {
          // 1. 清除视频缓存
          await LruCacheSingleton().storageClear();
          await LruCacheSingleton().memoryClear();

          // 2. 清除图片缓存
          await DefaultCacheManager().emptyCache();

          // 保险起见，手动清理图片缓存目录
          final cacheDir = await getTemporaryDirectory();
          final imageCacheDir = Directory('${cacheDir.path}/libCachedImageData');
          if (await imageCacheDir.exists()) {
            await imageCacheDir.delete(recursive: true);
          }

          // 3. 重新获取缓存大小更新 UI
          await getCacheSize();
          
          EasyLoading.dismiss();
          EasyLoading.showToast('Cache cleared successfully');
        } catch (e) {
          commonDebugPrint('Clear cache error: $e');
          EasyLoading.dismiss();
          EasyLoading.showToast('Failed to clear cache');
        }
      },
    );
  }

  Future<void> feedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'internationalscopesofficial@gmail.com',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        EasyLoading.showToast('Please send your suggestions to internationalscopesofficial@gmail.com');
      }
    } catch (e) {
      EasyLoading.showToast('Please send your suggestions to internationalscopesofficial@gmail.com');
    }
  }
}