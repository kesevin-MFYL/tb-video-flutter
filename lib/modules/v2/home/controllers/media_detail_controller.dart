import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_detail_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class MediaDetailController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  /// 媒体id
  late int mediaId;

  /// 媒体类型
  late int mediaType;

  MediaDetailEntity? mediaDetailEntity;

  var recommendList = <HomeSectionEntity>[];

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is Map<String, dynamic>) {
      mediaId = arguments['mediaId'];
      mediaType = arguments['mediaType'];
    }
  }

  @override
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() {
    if (mediaId != null) {
      Future.wait([_getMediaDetail(), _getMediaRecommend()]).then((list) {
        update();
      });
    }
  }

  Future<void> _getMediaDetail() async {
    final result = await HomeApi.getMediaDetail(id: mediaId);
    if (result.isSuccess) {
      mediaDetailEntity = result.responseData?.data;
      multiStatusType = mediaDetailEntity == null ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
  }

  Future<void> _getMediaRecommend() async {
    final result = await HomeApi.getMediaRecommend(id: mediaId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      recommendList = listData ?? [];
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  void viewInfoDetail() {

  }

  void mediaTap(MediaItemEntity mediaItem, SectionType sectionType) {
    if (sectionType == SectionType.mediaList || sectionType == SectionType.topPicks) {
      // 单片，进入视频播放页
      toMediaDetail(mediaItem);
    } else if (sectionType == SectionType.imdbList) {
      // 合集，进入合集二级页
      Get.toNamed(Routes.imdbListSubPage, arguments: mediaItem);
    } else if (sectionType == SectionType.imdbInterest) {
      // 进入分类详情页
      Get.toNamed(Routes.interestDetailPage, arguments: mediaItem);
    } else if (sectionType == SectionType.streamingMedia) {
      // 渠道，进入视频播放页
      toMediaDetail(mediaItem);
    }
  }

  void toMediaDetail(MediaItemEntity mediaItemEntity) {
    Get.toNamed(Routes.mediaDetailPage, arguments: {'mediaId': mediaItemEntity.id, 'mediaType': mediaItemEntity.type});
  }

  void saveMedia() {
    // Save history with new entity
    // final historyEntity = MediaHistoryEntity(
    //   id: mediaItemEntity.id,
    //   title: mediaItemEntity.title,
    //   cover: mediaItemEntity.cover,
    //   type: mediaItemEntity.type,
    //   viewTime: DateTime.now().millisecondsSinceEpoch,
    //   totalDuration: 0, // Placeholder or set real value if available
    //   currentDuration: 0, // Placeholder or set real value if available
    // );
    // Storage.addViewedMedia(historyEntity);
    //
    // EventBusManager.instance.post(EventBusName.historyRefresh);
  }
}
