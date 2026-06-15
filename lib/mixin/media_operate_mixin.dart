import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';

mixin MediaOperateMixin {
  /// 跳转媒体播放详情页 多开
  void toMediaDetailMultiPage({int? mediaId, int? mediaType}) {
    //todo 需要处理相同视频打开后，视频暂停未播放问题 例如：播放视频A，点击播放视频B，在B页面再次点击播放视频A，A视频暂停未播放
    Get.toNamed(
      Routes.mediaDetailPage,
      arguments: {'mediaId': mediaId, 'mediaType': mediaType},
      preventDuplicates: false,
    );
  }

  /// 跳转媒体播放详情页 单开
  void toMediaDetailSinglePage({int? mediaId, int? mediaType}) {
    if (mediaId == null || mediaType == null) return;

    if (Get.isRegistered<MediaDetailController>()) {
      // 已存在播放详情
      final controller = Get.find<MediaDetailController>();
      if (controller.mediaId != mediaId) {
        // 当前播放的视频和要打开的视频不一致
        controller.changePlay(mediaId: mediaId, mediaType: mediaType);
        return;
      }
      // 如果播放的视频相同，则直接返回
      Get.until((route) => Get.currentRoute == Routes.mediaDetailPage);
    } else {
      // 不存在会话
      Get.toNamed(Routes.mediaDetailPage, arguments: {'mediaId': mediaId, 'mediaType': mediaType});
    }
  }
}
