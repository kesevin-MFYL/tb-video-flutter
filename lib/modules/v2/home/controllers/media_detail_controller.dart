import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_detail_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/media/media_player_controller.dart';
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaDetailController extends BaseController with GetSingleTickerProviderStateMixin {
  var multiStatusType = MultiStatusType.statusLoading;

  /// 媒体id
  late int mediaId;

  /// 媒体类型
  late int mediaType;

  late VideoType videoType;

  /// 缓存记录
  MediaHistoryEntity? mediaHistoryEntity;

  MediaDetailEntity? mediaDetailEntity;

  var recommendList = <HomeSectionEntity>[];

  TabController? tabController;

  /// 季列表
  var seasonList = <SeasonEntity>[];

  /// 选中的季
  final selectSeason = Rx<SeasonEntity?>(null);

  /// 选中的集
  final selectEpisode = Rx<EpisodeEntity?>(null);

  /// 是否显示媒体详情弹窗
  var showBottomOtherInfo = false.obs;

  /// 是否显示剧集底部弹窗
  var showBottomSeasons = false.obs;

  Future<bool>? mediaPlayerFuture;

  double get bottomHeight => Get.height - safeAreaEdgeInsets.top - videoHeight;

  double get videoHeight => Get.width * 9 / 16;

  MediaPlayerController mediaPlayerController = MediaPlayerController();

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

      videoType = VideoType.instance(mediaType);

      mediaHistoryEntity = Storage.getViewedMediaById(mediaId);
    }
  }

  @override
  void handRegister() {
    /// 注册播放器记录事件
    mediaPlayerController.setRecrodAction(saveMedia);
  }

  @override
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() {
    Future.wait([_getMediaDetail(), _getMediaRecommend(), _getTvSeasons()]).then((list) {
      changeFutureAndTitle();
    });
  }

  void changeFutureAndTitle() {
    mediaPlayerFuture = initMediaPlayer();
    changeTitle();
    update();
  }

  void bottomOtherInfoChanged() {
    showBottomOtherInfo.value = !showBottomOtherInfo.value;
  }

  void bottomSeasonsChanged() {
    showBottomSeasons.value = !showBottomSeasons.value;
  }

  /// 选择剧集
  void chooseEpisode(EpisodeEntity episode) {
    selectEpisode.value = episode;
    if (tabController!.index < seasonList.length) {
      selectSeason.value = seasonList[tabController!.index];
    }
    changeFutureAndTitle();
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
    if (videoType != VideoType.tv) return;

    // 电视剧获取季
    final result = await HomeApi.getAllSeasons(id: mediaId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      seasonList = listData ?? [];

      if (tabController == null) {
        var initialIndex = 0;

        if (mediaHistoryEntity != null) {
          // 有缓存记录
          selectSeason.value = mediaHistoryEntity?.season;
          selectEpisode.value = mediaHistoryEntity?.episode;
          final seasonId = selectSeason.value?.id ?? 0;
          initialIndex = seasonList.indexWhere((element) => element.id == seasonId);
        } else {
          // 没有历史记录默认第一季
          selectSeason.value = seasonList.first;
        }

        tabController ??= TabController(initialIndex: initialIndex, length: seasonList.length, vsync: this);
      }
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
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
    //Save history with new entity
    final historyEntity = MediaHistoryEntity(
      id: mediaDetailEntity?.id,
      title: mediaDetailEntity?.title,
      cover: mediaDetailEntity?.cover,
      type: mediaType,
      viewTime: DateTime.now().millisecondsSinceEpoch,
      totalDuration: mediaPlayerController.totalDuration.value.inSeconds,
      currentDuration: mediaPlayerController.currentPosition.value.inSeconds,
      season: videoType == VideoType.tv ? selectSeason.value : null,
      episode: videoType == VideoType.tv ? selectEpisode.value : null,
    );
    Storage.addViewedMedia(historyEntity);

    EventBusManager.instance.post(EventBusName.historyRefresh);
  }

  /// 改变标题
  void changeTitle() {
    mediaPlayerController.changeMediaTitle(
      videoType == VideoType.video
          ? mediaDetailEntity?.title ?? ''
          : '${selectEpisode.value?.epsNum ?? 0} ${mediaDetailEntity?.title ?? ''} ${selectSeason.value?.title ?? ''}',
    );
  }

  Future<bool> initMediaPlayer() async {
    try {
      if (videoType == VideoType.video) {
        return await mediaPlayerController.setDataSource(
          MediaDataSource(
            videoSource: mediaDetailEntity?.video ?? '',
            videoType: videoType,
            type: MediaDataSourceType.network,
          ),
          initVideoPosition: mediaHistoryEntity != null && mediaHistoryEntity!.currentDuration != null
              ? Duration(seconds: mediaHistoryEntity!.currentDuration!)
              : Duration.zero,
        );
      } else {
        if (selectEpisode.value != null) {
          return await mediaPlayerController.setDataSource(
            MediaDataSource(
              videoSource: selectEpisode.value?.video ?? '',
              videoType: videoType,
              type: MediaDataSourceType.network,
            ),
            initVideoPosition: mediaHistoryEntity != null && mediaHistoryEntity!.currentDuration != null
                ? Duration(seconds: mediaHistoryEntity!.currentDuration!)
                : Duration.zero,
          );
        }
      }
      return false;
    } catch (e) {
      commonDebugPrint(e);
    }
    return false;
  }

  @override
  void onClose() {
    mediaPlayerController.dispose();
    tabController?.dispose();
    super.onClose();
  }
}
