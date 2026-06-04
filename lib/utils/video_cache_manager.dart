import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class VideoCacheManager extends CacheManager {
  static const key = 'videoCacheData';
  static const int maxCacheSizeBytes = 2 * 1024 * 1024 * 1024; // 2GB

  static VideoCacheManager? _instance;

  factory VideoCacheManager() {
    _instance ??= VideoCacheManager._();
    return _instance!;
  }

  VideoCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 500,
        ));

  Future<void> checkAndCleanCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final videoCacheDir = Directory('${cacheDir.path}/$key');
      if (!await videoCacheDir.exists()) return;

      int totalSize = 0;
      final List<FileSystemEntity> files = videoCacheDir.listSync(recursive: true);
      final List<File> cacheFiles = [];

      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
          cacheFiles.add(file);
        }
      }

      if (totalSize > maxCacheSizeBytes) {
        // Sort by last modified time ascending (oldest first)
        cacheFiles.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

        for (var file in cacheFiles) {
          if (totalSize <= maxCacheSizeBytes) break;
          final fileSize = await file.length();
          await file.delete();
          totalSize -= fileSize;
        }
      }
    } catch (e) {
      print('Clean cache error: $e');
    }
  }
}
