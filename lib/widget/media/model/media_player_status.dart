import 'package:get/get.dart';

enum MediaPlayerStatusType { completed, playing, paused }

class MediaPlayerStatus {
  Rx<MediaPlayerStatusType> status = Rx(MediaPlayerStatusType.paused);

  bool get playing {
    return status.value == MediaPlayerStatusType.playing;
  }

  bool get paused {
    return status.value == MediaPlayerStatusType.paused;
  }

  bool get completed {
    return status.value == MediaPlayerStatusType.completed;
  }
}