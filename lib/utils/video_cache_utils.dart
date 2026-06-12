import 'package:flutter_video_caching/flutter_video_caching.dart';

class VideoCacheUtils {
  static Future<void> clearCache(String videoUrl) async {
    try {
      await LruCacheSingleton().removeCacheByUrl(videoUrl);
    } catch (e) {
      // ignore
    }
  }
}