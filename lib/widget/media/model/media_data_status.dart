import 'package:get/get.dart';

enum MediaDataStatusType { none, loading, completed, error }

/// 媒体数据状态
class MediaDataStatus {
  Rx<MediaDataStatusType> status = Rx(MediaDataStatusType.none);

  bool get none => status.value == MediaDataStatusType.none;

  bool get loading => status.value == MediaDataStatusType.loading;

  bool get completed => status.value == MediaDataStatusType.completed;

  bool get error => status.value == MediaDataStatusType.error;
}
