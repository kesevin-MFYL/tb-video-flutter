import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_detail_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MediaDetailController extends BaseController with GetSingleTickerProviderStateMixin {
  var multiStatusType = MultiStatusType.statusLoading;

  /// 媒体id
  late int mediaId;

  /// 媒体类型
  late int mediaType;

  MediaDetailEntity? mediaDetailEntity;

  var recommendList = <HomeSectionEntity>[];

  TabController? tabController;

  /// 季列表
  var seasonList = <SeasonEntity>[];

  /// 季id
  var seasonId = -1;

  /// 集id
  var episodeId = -1;

  /// 是否显示媒体详情弹窗
  var showBottomOtherInfo = false.obs;

  /// 是否显示剧集底部弹窗
  var showBottomSeasons = false.obs;

  double get bottomHeight => Get.height - safeAreaEdgeInsets.top - 212.w;

  void reload() {
    multiStatusType = MultiStatusType.statusLoading;
    update();
    getDataFromServer();
  }

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
      Future.wait([_getMediaDetail(), _getMediaRecommend(), _getTvSeasons()]).then((list) {
        update();
      });
    }
  }

  void bottomOtherInfoChanged() {
    showBottomOtherInfo.value = !showBottomOtherInfo.value;
  }

  void bottomSeasonsChanged() {
    showBottomSeasons.value = !showBottomSeasons.value;
  }

  /// 切换季
  void changeSeason(int index) {
    seasonId = seasonList[index].id ?? -1;
  }

  /// 获取媒体详情
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

  /// 获取媒体推荐
  Future<void> _getMediaRecommend() async {
    final result = await HomeApi.getMediaRecommend(id: mediaId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      recommendList = listData ?? [];
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  /// 获取所有季
  Future<void> _getTvSeasons() async {
    if (mediaType != 2) return;
    final result = await HomeApi.getAllSeasons(id: mediaId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      seasonList = listData ?? [];

      if (seasonId == -1) {
        //todo 判断是否有缓存 播放缓存中的季， 没有缓存播放第一季
        seasonId = seasonList.first.id ?? -1;
      }

      final initialIndex = seasonList.indexWhere((element) => element.id == seasonId);
      tabController ??= TabController(initialIndex: initialIndex, length: seasonList.length, vsync: this);
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  void viewInfoDetail() {}

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

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
