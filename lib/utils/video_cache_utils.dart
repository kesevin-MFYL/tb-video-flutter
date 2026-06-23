import 'package:flutter_video_caching/flutter_video_caching.dart';

class VideoCacheUtils {
  static Future<void> clearCache(String videoUrl) async {
    try {
      final String path = videoUrl.split('?').first.toLowerCase();
      final bool isMp4 = path.endsWith('.mp4');
      await LruCacheSingleton().removeCacheByUrl(videoUrl, singleFile: isMp4);
    } catch (e) {
      // ignore
    }
  }
}