import 'dart:io';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/asset_manager.dart';
import 'package:editvideo/models/video_info.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/permission_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class EditVideoController extends BaseController {
  VideoInfo? videoInfo;

  var isThumbnailLoading = false;

  @override
  void handArguments(arguments) {}

  void pickVideo() async {
    /// 获取视频权限
    final permission = await PermissionUtils.videos();
    if (permission == false) return;

    final assetEntity = await AssetManager.instance.pickVideos();
    if (assetEntity != null) {
      isThumbnailLoading = true;
      final file = await assetEntity.file;
      final fileLength = await file?.length();
      videoInfo = VideoInfo(
        width: assetEntity?.width ?? 0,
        height: assetEntity?.height ?? 0,
        duration: assetEntity?.duration ?? 0,
        size: fileLength ?? 0,
        path: file?.path ?? '',
      );
      update();
      // 获取视频封面
      await _loadThumbnail();
    }
  }

  /// 获取视频封面
  Future<void> _loadThumbnail() async {
    if (videoInfo == null || videoInfo!.path.isEmptyString()) return;
    try {
      final directory = await getTemporaryDirectory();
      final thumbnailName = "${videoInfo!.path?.buildFileName()}.webp";
      final thumbnailPath = "${directory.path}/video_cover_$thumbnailName";

      if (File(thumbnailPath).existsSync()) {
        videoInfo!.thumbnailPath = thumbnailPath;
        isThumbnailLoading = false;
        update();
        return;
      }
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoInfo!.path!,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.WEBP,
        maxHeight: 375,
        quality: 80,
      );

      if (thumbnail != null && File(thumbnail).existsSync()) {
        videoInfo!.thumbnailPath = thumbnail;
        isThumbnailLoading = false;
      } else {
        commonDebugPrint("video---Failed to generate thumbnail.");
        isThumbnailLoading = false;
      }
      update();
    } catch (e) {
      commonDebugPrint("video---Error loading thumbnail: $e");
      isThumbnailLoading = false;
      update();
    }
  }

}
