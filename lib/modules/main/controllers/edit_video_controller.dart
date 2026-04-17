import 'dart:io';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/asset_manager.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/models/video_info.dart';
import 'package:editvideo/modules/home/controllers/draft_controller.dart';
import 'package:editvideo/modules/home/controllers/my_memory_controller.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/permission_util.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/bottom_sheet/date_time_bottom_sheet_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:uuid/uuid.dart';

class EditVideoController extends BaseController {
  VideoInfo? videoInfo;
  MemoryInfo? initialMemoryInfo;
  bool isEditMode = false;
  bool isFromDraft = false;

  var isThumbnailLoading = false;

  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final personController = TextEditingController();
  final memoController = TextEditingController();

  DateTime? chooseDate;

  var saveEnable = false.obs;

  void checkSaveBtnEnabled() => saveEnable.value = videoInfo != null && titleController.text.trim().isNotEmptyString();

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is Map<String, dynamic>) {
      isEditMode = true;
      initialMemoryInfo = arguments['memoryInfo'];
      isFromDraft = arguments['isFromDraft'] ?? false;
      
      if (initialMemoryInfo != null) {
        if (initialMemoryInfo!.videoInfo != null) {
          videoInfo = initialMemoryInfo!.videoInfo!.copyWith();
        }
        titleController.text = initialMemoryInfo!.title ?? '';
        personController.text = initialMemoryInfo!.person ?? '';
        memoController.text = initialMemoryInfo!.memo ?? '';
        update();
      }
    }
  }

  void pickVideo() async {
    unfocus();
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
      checkSaveBtnEnabled();
      update();
      // 获取视频封面
      await _loadThumbnail();
    }
  }

  void deleteVideo() {
    videoInfo = null;
    checkSaveBtnEnabled();
    update();
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

  void toback() {
    final currentTitle = titleController.text.trim();
    final currentPerson = personController.text.trim();
    final currentMemo = memoController.text.trim();

    if (!isEditMode) {
      // 新增的情况
      if (videoInfo != null) {
        // 已选择视频，保存为草稿（不拷贝视频文件到app文档目录）
        final draftInfo = MemoryInfo(
          id: const Uuid().v4(),
          videoInfo: videoInfo,
          title: currentTitle,
          person: currentPerson,
          memo: currentMemo,
          videoTime: DateTime.now().millisecondsSinceEpoch,
        );
        Storage.addDraftMemory(draftInfo);
        Get.find<DraftController>().getDataFromLocal();
      }

      // 如果没有选择视频，直接关闭页面
      Get.back();
    } else {
      // 编辑的情况
      if (videoInfo != null) {
        bool hasChanged = false;
        if (videoInfo?.path != initialMemoryInfo?.videoInfo?.path ||
            currentTitle != (initialMemoryInfo?.title ?? '') ||
            currentPerson != (initialMemoryInfo?.person ?? '') ||
            currentMemo != (initialMemoryInfo?.memo ?? '')) {
          hasChanged = true;
        }

        if (hasChanged) {
          // 内容发生变化
          String draftId;
          if (isFromDraft) {
            // 如果是从草稿列表进入的，更新存储中对应的草稿数据
            draftId = initialMemoryInfo!.id ?? const Uuid().v4();
          } else {
            // 如果是从保存的数据列表进入的，每次新增一条草稿数据
            draftId = const Uuid().v4();
          }

          final draftInfo = MemoryInfo(
            id: draftId,
            videoInfo: videoInfo,
            title: currentTitle,
            person: currentPerson,
            memo: currentMemo,
            videoTime: initialMemoryInfo?.videoTime ?? DateTime.now().millisecondsSinceEpoch,
          );
          Storage.addDraftMemory(draftInfo);

          Get.find<DraftController>().getDataFromLocal();
        }
      }

      // 直接关闭页面
      Get.back();
    }
  }

  Future<void> save() async {
    try {
      // 保存视频文档到app内
      final appDocDir = await getApplicationDocumentsDirectory();
      final videoFileName = videoInfo!.path!.split('/').last;
      final savedVideoPath = '${appDocDir.path}/$videoFileName';
      
      final originalFile = File(videoInfo!.path!);
      if (originalFile.existsSync() && videoInfo!.path != savedVideoPath) {
        await originalFile.copy(savedVideoPath);
        videoInfo!.path = savedVideoPath;
      }

      // 保存封面（如果有的话）
      if (videoInfo!.thumbnailPath != null) {
        final thumbFile = File(videoInfo!.thumbnailPath!);
        if (thumbFile.existsSync()) {
          final thumbName = videoInfo!.thumbnailPath!.split('/').last;
          final savedThumbPath = '${appDocDir.path}/$thumbName';
          if (videoInfo!.thumbnailPath != savedThumbPath) {
            await thumbFile.copy(savedThumbPath);
            videoInfo!.thumbnailPath = savedThumbPath;
          }
        }
      }

      // 创建或更新 MemoryInfo
      final memoryInfo = MemoryInfo(
        id: isEditMode ? initialMemoryInfo!.id : const Uuid().v4(),
        videoInfo: videoInfo,
        title: titleController.text.trim(),
        person: personController.text.trim(),
        memo: memoController.text.trim(),
        videoTime: isEditMode ? (initialMemoryInfo!.videoTime ?? DateTime.now().millisecondsSinceEpoch) : DateTime.now().millisecondsSinceEpoch,
      );

      // 添加到保存列表
      await Storage.addSavedMemory(memoryInfo);

      if (isEditMode && isFromDraft) {
        await Storage.deleteDraftMemory(initialMemoryInfo!.id!);
        Get.find<DraftController>().getDataFromLocal();
      }

      Get.find<MyMemoryController>().getDataFromLocal();

      Get.back();

    } catch (e) {
      commonDebugPrint("video---Save failed: $e");
    }
  }

  void showDateTimePicker() {
    DateTimeBottomSheetView.show(
      initialDate: chooseDate,
      onChanged: (date) {
        chooseDate = date;
      },
    );
  }
}
