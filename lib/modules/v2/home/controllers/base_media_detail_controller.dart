import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/mixin/media_operate_mixin.dart';
import 'package:editvideo/models/caption_entity.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_detail_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/utils/video_cache_utils.dart';
import 'package:editvideo/widget/media/media_player_controller.dart';
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../../widget/page_status/multi_status_view.dart';

class BaseMediaDetailController extends BaseController with GetSingleTickerProviderStateMixin, MediaOperateMixin {

  TabController? tabController;

  /// 详情状态
  var multiStatusType = MultiStatusType.statusLoading;

  /// 集列表状态
  var episodeStatusType = MultiStatusType.statusContent.obs;

  /// 媒体播放控制器
  MediaPlayerController mediaPlayerController = MediaPlayerController();

  /// 媒体id
  late int mediaId;

  /// 媒体类型
  late int mediaType;

  /// 视频类型
  late VideoType videoType;

  /// 缓存记录
  MediaHistoryEntity? mediaHistoryEntity;

  /// 媒体详情信息
  MediaDetailEntity? mediaDetailEntity;

  /// 季列表
  var seasonList = <SeasonEntity>[];

  /// 集列表
  var episodeList = <EpisodeEntity>[];

  /// 缓存各季的集列表
  final Map<int, List<EpisodeEntity>> episodeListCache = {};

  /// 推荐列表
  var recommendList = <HomeSectionEntity>[];

  /// 字幕列表
  var captionList = <CaptionEntity>[];

  /// 选中的季
  final selectSeason = Rx<SeasonEntity?>(null);

  /// 选中的集
  final selectEpisode = Rx<EpisodeEntity?>(null);

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
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() {
    Future.wait([_getMediaDetail(), _getMediaRecommend(), _getTvSeasons()]).then((list) {
      updateMediaAndTitle();
      EasyLoading.dismiss();
    });
  }

  /// 获取媒体详情
  Future<void> _getMediaDetail() async {
    final result = await HomeApi.getMediaDetail(id: mediaId);
    if (result.isSuccess) {
      mediaDetailEntity = result.responseData?.data;

      // 字幕
      captionList = mediaDetailEntity?.captionList ?? [];

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

      // 获取所有季下的所有集
      for (var season in seasonList) {
        await _getEpisodeList(seasonId: season.id);
      }

      // 选中的季，没有缓存记录默认第一季
      selectSeason.value = seasonList.firstWhereOrNull((element) => element.id == mediaHistoryEntity?.season?.id) ?? seasonList.first;
      var initialIndex = seasonList.indexWhere((element) => element.id == selectSeason.value?.id);

      // 选中的集，没有缓存记录默认第一集
      episodeList = episodeListCache[selectSeason.value?.id] ?? [];
      selectEpisode.value = episodeList.firstWhereOrNull((element) => element.id == mediaHistoryEntity?.episode?.id) ?? episodeList.first;

      // 检查是否有下一集
      checkHasNextPlay();

      // 字幕
      captionList = selectEpisode.value?.captionList ?? [];

      tabController ??= TabController(length: seasonList.length, vsync: this);
      tabController!.index = initialIndex == -1 ? 0 : initialIndex;
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  /// 获取季下的所有集
  Future<void> _getEpisodeList({int? seasonId}) async {
    if (videoType != VideoType.tv || seasonId == null) return;
    if (episodeListCache.containsKey(seasonId)) {
      return;
    }

    final result = await HomeApi.getSeasonAllEpisodes(id: seasonId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      episodeListCache[seasonId!] = listData ?? [];
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  /// 检查是否有下一集
  void checkHasNextPlay() {
    // 判断当前是否为最后一季的最后的最后一集
    final currentSeason = selectSeason.value;
    final currentEpisode = selectEpisode.value;
    if (currentSeason != null && currentEpisode != null) {
      final episodeIndex = episodeList.indexOf(currentEpisode);
      final seasonIndex = seasonList.indexOf(currentSeason);
      if (seasonIndex != -1 &&
          seasonIndex == seasonList.length - 1 &&
          episodeIndex != -1 &&
          episodeIndex == episodeList.length - 1) {
        mediaPlayerController.hasNextEpisode.value = false;
      } else {
        mediaPlayerController.hasNextEpisode.value = true;
      }
    } else {
      mediaPlayerController.hasNextEpisode.value = true;
    }
  }

  /// 选择剧集
  void chooseEpisode(EpisodeEntity episode) {
    if (tabController!.index >= seasonList.length) return;

    selectEpisode.value = episode;
    captionList = selectEpisode.value?.captionList ?? [];
    if (tabController!.index < seasonList.length) {
      selectSeason.value = seasonList[tabController!.index];
    }

    //检查是否有下一集
    checkHasNextPlay();

    updateMediaAndTitle();
  }

  /// 季Tab切换
  void seasonTabChanged(int tabIndex) {
    final seasonId = seasonList[tabIndex].id;
    episodeList = episodeListCache[seasonId] ?? [];
    update();
  }

  /// 重置播放器和更新标题
  void updateMediaAndTitle() {
    openMediaData();
    updateTitle();
    update();
  }

  /// 修改标题
  void updateTitle() {
    mediaPlayerController.changeMediaTitle(
      videoType == VideoType.video
          ? mediaDetailEntity?.title ?? ''
          : '${selectEpisode.value?.epsNum ?? 0} ${mediaDetailEntity?.title ?? ''} ${selectSeason.value?.title ?? ''}',
    );
  }

  void openMediaData({bool isReload = false}) async {
    try {
      /// 注册播放器记录事件
      mediaPlayerController.setRecrodAction(saveMedia);

      if (videoType == VideoType.video) {
        await mediaPlayerController.setDataSource(
          MediaDataSource(
            videoSource: mediaDetailEntity?.video ?? '',
            videoType: videoType,
            type: MediaDataSourceType.network,
          ),
          initVideoPosition: mediaPlayerController.firstLoad && mediaHistoryEntity != null && mediaHistoryEntity!.currentDuration != null
              ? Duration(seconds: mediaHistoryEntity!.currentDuration!)
              : isReload && mediaPlayerController.currentPosition.value.inSeconds > 0
              ? mediaPlayerController.currentPosition.value
              : Duration.zero,
          captionList: captionList,
        );
      } else {
        if (selectEpisode.value != null) {
          await mediaPlayerController.setDataSource(
            MediaDataSource(
              videoSource: selectEpisode.value?.video ?? '',
              videoType: videoType,
              type: MediaDataSourceType.network,
            ),
            initVideoPosition: mediaPlayerController.firstLoad && mediaHistoryEntity != null && mediaHistoryEntity!.currentDuration != null
                ? Duration(seconds: mediaHistoryEntity!.currentDuration!)
                : isReload && mediaPlayerController.currentPosition.value.inSeconds > 0
                ? mediaPlayerController.currentPosition.value
                : Duration.zero,
            captionList: captionList,
          );
        }
      }
    } catch (e) {
      commonDebugPrint(e);
    }
  }

  /// 当前视频播放完毕或手动切换，播放下一个视频
  void nextPlay() async {
    // 影片播放完毕
    if (videoType == VideoType.video) {
      if (recommendList.isNotEmpty) {
        // 推荐列表中单片列表的第一个影片
        MediaItemEntity? firstRecommendItem;
        // 获取推荐中的第一个单片对象
        final homeSectionItem = recommendList.firstWhereOrNull((element) {
          final sectionType = SectionType.kind(element.kind);
          return sectionType == SectionType.mediaList;
        });
        if (homeSectionItem != null) {
          if (homeSectionItem.dataList != null && homeSectionItem.dataList!.isNotEmpty) {
            firstRecommendItem = homeSectionItem.dataList!.first;
          }
        }
        if (firstRecommendItem != null) {
          // 重置并切换播放源
          changePlay(mediaId: firstRecommendItem.id ?? 0, mediaType: firstRecommendItem.type ?? 1);
        }
      }
    } else if (videoType == VideoType.tv) {
      // 剧集播放完毕
      final currentSeason = selectSeason.value;
      final currentEpisode = selectEpisode.value;
      if (currentSeason != null && currentEpisode != null) {
        final episodeIndex = episodeList.indexOf(currentEpisode);
        final seasonIndex = seasonList.indexOf(currentSeason);

        if (episodeIndex != -1 && episodeIndex < episodeList.length - 1) {
          // 不是最后一集,播放下一集
          mediaPlayerController.setRecrodAction(null);
          final nextEpisode = episodeList[episodeIndex + 1];
          chooseEpisode(nextEpisode);
        } else if (episodeIndex != -1 && episodeIndex == episodeList.length - 1) {
          // 最后一集
          if (seasonIndex != -1 && seasonIndex < seasonList.length - 1) {
            // 不是最后一季,播放下一季第一集
            mediaPlayerController.setRecrodAction(null);
            selectSeason.value = seasonList[seasonIndex + 1];
            episodeList = episodeListCache[selectSeason.value?.id] ?? [];
            selectEpisode.value = episodeList.first;
            tabController?.animateTo(seasonIndex + 1);
            chooseEpisode(selectEpisode.value!);
          } else if (seasonIndex != -1 && seasonIndex == seasonList.length - 1) {
            // 是最后一季
          }
        }
      }
    }
  }

  /// 切换播放
  void changePlay({required int mediaId, required int mediaType}) async {
    EasyLoading.show();
    this.mediaId = mediaId;
    this.mediaType = mediaType;
    videoType = VideoType.instance(mediaType);
    mediaHistoryEntity = Storage.getViewedMediaById(mediaId);
    mediaPlayerController.setRecrodAction(null);
    getDataFromServer();
  }

  /// 保存播放记录
  void saveMedia() {
    if (mediaPlayerController.mediaPlayerStatus.completed) {
      // 播放完成删除 缓存
      VideoCacheUtils.clearCache(videoType == VideoType.video ? mediaDetailEntity?.video ?? '' : selectEpisode.value?.video ?? '');
    } else {
      //Save history with new entity
      final historyEntity = MediaHistoryEntity(
        id: mediaDetailEntity?.id,
        title: mediaDetailEntity?.title,
        cover: mediaDetailEntity?.cover,
        type: mediaType,
        videoUrl: videoType == VideoType.video ? mediaDetailEntity?.video ?? '' : selectEpisode.value?.video ?? '',
        viewTime: DateTime.now().millisecondsSinceEpoch,
        totalDuration: mediaPlayerController.totalDuration.value.inSeconds,
        currentDuration: mediaPlayerController.currentPosition.value.inSeconds,
        season: videoType == VideoType.tv ? selectSeason.value : null,
        episode: videoType == VideoType.tv ? selectEpisode.value : null,
      );

      Storage.addViewedMedia(historyEntity);
    }

    EventBusManager.instance.post(EventBusName.historyRefresh);
  }
}
