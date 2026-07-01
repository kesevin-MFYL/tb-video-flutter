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
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/widget/media/model/media_player_status.dart';
import 'package:editvideo/widget/media/video_player_controller.dart';
import 'package:editvideo/mixin/video_ad_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../../widget/page_status/multi_status_view.dart';

class BaseVideoDetailController extends BaseController with GetTickerProviderStateMixin, MediaOperateMixin, VideoAdMixin {
  TabController? tabController;

  /// 详情状态
  var multiStatusType = MultiStatusType.statusLoading;

  /// 集列表状态
  var episodeStatusType = MultiStatusType.statusLoading.obs;

  /// 媒体播放控制器
  PlayerController mediaPlayerController = PlayerController();

  /// 是否多窗口播放视频
  bool isMultiOpen = false;

  /// 是否首次加载集列表
  bool isFirstLoadEpisode = true;

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

  /// 是否正在显示暂停广告
  final isShowingPauseAd = false.obs;

  /// 是否正在显示PlayPoint中间广告（横屏）
  final isShowingPlayMiddleAd = false.obs;

  /// 是否触发了PlayPoint节点（用于防止pause广告重复触发）
  final isShowingPlayPointAd = false.obs;

  /// 上一次触发广告的时间节点索引
  int _lastPlayPointAdIndex = 0;

  @override
  void onInit() {
    super.onInit();
    mediaPlayerController.addStatusLister((status) {
      if (status == MediaPlayerStatusType.paused) {
        if (!mediaPlayerController.isBuffering.value &&
            mediaPlayerController.currentPosition.value.inSeconds > 0 &&
            mediaPlayerController.currentPosition.value < mediaPlayerController.totalDuration.value || !mediaPlayerController.isSliderMoving.value) {
          if (!isShowingPlayPointAd.value) {
            showPauseAd();
          }
        }
      } else if (status == MediaPlayerStatusType.playing) {
        closePauseAd();
        closePlayMiddleAd();
      }
    });

    ever(mediaPlayerController.currentPosition, (Duration position) {
      if (mediaPlayerController.isSliderMoving.value) return;

      final config = RemoteConfigManager().config;
      if (config != null && config.playPointTime > 0) {
        // 当前播放进度秒数
        int currentSeconds = position.inSeconds;
        // 如果正好到达了 playPointTime 的整数倍节点（并且不是0）
        if (currentSeconds > 0 && currentSeconds % config.playPointTime == 0) {
          int currentIndex = currentSeconds ~/ config.playPointTime;
          // 防止同一秒内多次触发，必须大于上一次触发的节点索引
          if (currentIndex > _lastPlayPointAdIndex) {
            _lastPlayPointAdIndex = currentIndex;
            _triggerPlayPointAd();
          }
        } else {
          // 如果当前时间不到 playPointTime，或者是跨越了但并非“正好等于”，则只更新索引以便后续可以触发更大的节点
          int currentIndex = currentSeconds ~/ config.playPointTime;
          if (currentIndex < _lastPlayPointAdIndex) {
            _lastPlayPointAdIndex = currentIndex;
          }
        }
      }
    });

    ever(mediaPlayerController.isSliderMoving, (isMoving) {
      if (isMoving) {
        closePauseAd();
        closePlayMiddleAd();
      } else {
        // 拖动结束时，只需重置 _lastPlayPointAdIndex 到当前位置，不触发广告
        final position = mediaPlayerController.currentPosition.value;
        final config = RemoteConfigManager().config;
        if (config != null && config.playPointTime > 0) {
          _lastPlayPointAdIndex = position.inSeconds ~/ config.playPointTime;
        }
      }
    });
  }

  void _triggerPlayPointAd() {
    if (mediaPlayerController.isFullscreen) {
      if (NativeAdManager.instance.isAdLoaded('play_middle')) {
        isShowingPlayPointAd.value = true;
        mediaPlayerController.pause();
        isShowingPlayMiddleAd.value = true;
      }
    } else {
      bool canShow = AdManager.instance.isAdAvailable('level_h') ||
          AdManager.instance.isAdAvailable('behavior') ||
          AdManager.instance.isAdAvailable('behavior2');
      if (canShow) {
        isShowingPlayPointAd.value = true;
        mediaPlayerController.pause();
        tryShowDualAds();
      }
    }
  }

  void closePlayMiddleAd() {
    if (isShowingPlayMiddleAd.value) {
      isShowingPlayMiddleAd.value = false;
      isShowingPlayPointAd.value = false;
      NativeAdManager.instance.disposeAd('play_middle');
      requestAd('play_middle');
    }
  }

  @override
  void onClose() {
    if (isShowingPauseAd.value) {
      NativeAdManager.instance.disposeAd('pause');
    }
    super.onClose();
  }

  void showPauseAd() {
    if (NativeAdManager.instance.isAdLoaded('pause')) {
      isShowingPauseAd.value = true;
    }
  }

  void closePauseAd() {
    if (isShowingPauseAd.value) {
      isShowingPauseAd.value = false;
      NativeAdManager.instance.disposeAd('pause');
      requestAd('pause');
    }
  }

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is Map<String, dynamic>) {
      isMultiOpen = arguments['isMultiOpen'] ?? false;

      mediaId = arguments['mediaId'];
      mediaType = arguments['mediaType'];

      videoType = VideoType.instance(mediaType);

      mediaHistoryEntity = Storage.getViewedMediaById(mediaId);
    }
  }

  @override
  void fetchData() {
    // 进入播放页后开始请求播放暂停广告
    requestAd('pause');
    getDataFromServer();
  }

  void getDataFromServer() {
    Future.wait([_getMediaDetail(), _getMediaRecommend(), _getTvSeasons()]).then((list) {
      if (EasyLoading.isShow) {
        EasyLoading.dismiss();
      }
      updateMediaAndTitle();
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
    if (videoType == VideoType.video) return;

    if (videoType == VideoType.tv) {
      // 电视剧获取季
      final result = await HomeApi.getAllSeasons(id: mediaId);
      if (result.isSuccess) {
        final listData = result.responseData?.data;
        seasonList = listData ?? [];

        if (seasonList.isEmpty) {
          episodeStatusType.value = MultiStatusType.statusEmpty;
          tabController = TabController(length: 0, vsync: this);
          return;
        }

        // 选中的季，没有缓存记录默认第一季
        selectSeason.value =
            seasonList.firstWhereOrNull((element) => element.id == mediaHistoryEntity?.season?.id) ?? seasonList.first;
        var initialIndex = seasonList.indexWhere((element) => element.id == selectSeason.value?.id);

        // 如果不是多开窗口 提前获取所有季下的所有集
        if (!isMultiOpen) {
          // 获取所有季下的所有集
          for (var season in seasonList) {
            await getEpisodeList(seasonId: season.id);
          }

          episodeStatusType.value = MultiStatusType.statusContent;

          // 选中的集，没有缓存记录默认第一集
          episodeList = episodeListCache[selectSeason.value?.id] ?? [];
          selectEpisode.value =
              episodeList.firstWhereOrNull((element) => element.id == mediaHistoryEntity?.episode?.id) ??
              episodeList.first;

          // 字幕
          captionList = selectEpisode.value?.captionList ?? [];
        }

        tabController = TabController(length: seasonList.length, vsync: this);
        tabController?.index = initialIndex == -1 ? 0 : initialIndex;

        // 如果是多开窗口 每次单独获取每季下的所有季
        if (isMultiOpen) {
          // 获取季下的所有集
          await getEpisodeList(seasonId: selectSeason.value?.id);
        }
      } else {
        commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      }
    } else if (videoType == VideoType.anime) {
      // 动漫获取集
      final result = await HomeApi.getAnimeAllEpisodes(id: mediaId);
      if (result.isSuccess) {
        final listData = result.responseData?.data;
        episodeList = listData ?? [];

        if (episodeList.isEmpty) {
          episodeStatusType.value = MultiStatusType.statusContent;
          return;
        }

        episodeStatusType.value = MultiStatusType.statusContent;

        selectEpisode.value =
            episodeList.firstWhereOrNull((element) => element.id == mediaHistoryEntity?.episode?.id) ??
            episodeList.first;

        // 字幕
        captionList = selectEpisode.value?.captionList ?? [];
      } else {
        commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      }
    }
  }

  /// 获取季下的所有集
  Future<void> getEpisodeList({int? seasonId}) async {
    if (videoType != VideoType.tv || seasonId == null) return;
    if (episodeListCache.containsKey(seasonId)) {
      if (isMultiOpen) {
        episodeList = episodeListCache[seasonId] ?? [];
        _handleEpisodeListSuccess();
      }
      return;
    }

    final result = await HomeApi.getSeasonAllEpisodes(id: seasonId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      episodeListCache[seasonId] = listData ?? [];

      if (isMultiOpen) {
        episodeList = listData ?? [];
        _handleEpisodeListSuccess();
      }
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      if (isMultiOpen) {
        episodeStatusType.value = MultiStatusType.statusError;
      }
    }
  }

  /// 多开视频窗口会执行
  void _handleEpisodeListSuccess() {
    if (isFirstLoadEpisode) {
      isFirstLoadEpisode = false;

      if (episodeList.isNotEmpty) {
        // 没有缓存记录默认第一集
        selectEpisode.value =
            episodeList.firstWhereOrNull((element) => element.id == mediaHistoryEntity?.episode?.id) ??
            episodeList.first;

        captionList = selectEpisode.value?.captionList ?? [];
      }
    }

    episodeStatusType.value = episodeList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    EasyLoading.dismiss();
  }

  /// 选择剧集
  void chooseEpisode(EpisodeEntity episode) {
    closePauseAd();
    closePlayMiddleAd();
    if (videoType == VideoType.tv) {
      if (tabController == null || tabController!.index >= seasonList.length) return;

      if (tabController!.index < seasonList.length) {
        selectSeason.value = seasonList[tabController!.index];
      }
    }
    selectEpisode.value = episode;
    captionList = selectEpisode.value?.captionList ?? [];

    updateMediaAndTitle();
  }

  /// 季Tab切换
  void seasonTabChanged(int tabIndex) {
    if (isMultiOpen) {
      episodeStatusType.value = MultiStatusType.statusLoading;
      getEpisodeList(seasonId: seasonList[tabIndex].id);
    } else {
      final seasonId = seasonList[tabIndex].id;
      episodeList = episodeListCache[seasonId] ?? [];
      update();
    }
  }

  /// 重置播放器和更新标题
  void updateMediaAndTitle() {
    updateTitle();
    bool didShowAd = tryShowDualAds();
    openMediaData(isReload: false, autoPlay: !didShowAd);
    update();
  }

  @override
  void allAdClosed() {
    isShowingPlayPointAd.value = false;
    mediaPlayerController.play();
  }

  /// 修改标题
  void updateTitle() {
    mediaPlayerController.changeMediaTitle(
      videoType == VideoType.video
          ? mediaDetailEntity?.title ?? ''
          : '${selectEpisode.value?.epsNum ?? 0} ${mediaDetailEntity?.title ?? ''} ${selectSeason.value?.title ?? ''}',
    );
  }

  void openMediaData({bool isReload = false, bool autoPlay = true}) async {
    try {
      /// 注册播放器记录事件
      mediaPlayerController.autoPlay = autoPlay;
      mediaPlayerController.setRecrodAction(saveMedia);
      final lastPosition = mediaPlayerController.currentPosition.value;
      if (videoType == VideoType.video) {
        await mediaPlayerController.setDataSource(
          MediaDataSource(
            videoSource: mediaDetailEntity?.video ?? '',
            videoType: videoType,
            type: MediaDataSourceType.network,
          ),
          initVideoPosition:
              mediaPlayerController.firstLoad &&
                  mediaHistoryEntity != null &&
                  mediaHistoryEntity!.currentDuration != null
              ? Duration(seconds: mediaHistoryEntity!.currentDuration!)
              : isReload && mediaPlayerController.currentPosition.value.inSeconds > 0
              ? lastPosition
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
            initVideoPosition:
                mediaPlayerController.firstLoad &&
                    mediaHistoryEntity != null &&
                    mediaHistoryEntity!.currentDuration != null
                ? Duration(seconds: mediaHistoryEntity!.currentDuration!)
                : isReload && mediaPlayerController.currentPosition.value.inSeconds > 0
                ? lastPosition
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
    closePauseAd();
    closePlayMiddleAd();
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
            if (isMultiOpen) {
              EasyLoading.show();
              await getEpisodeList(seasonId: selectSeason.value?.id);
            } else {
              episodeList = episodeListCache[selectSeason.value?.id] ?? [];
            }
            if (episodeList.isNotEmpty) {
              selectEpisode.value = episodeList.first;
              tabController?.animateTo(seasonIndex + 1);
              if (selectEpisode.value != null) {
                chooseEpisode(selectEpisode.value!);
              }
            }
          } else if (seasonIndex != -1 && seasonIndex == seasonList.length - 1) {
            // 是最后一季
          }
        }
      }
    } else if (videoType == VideoType.anime) {
      // 动漫剧集播放完毕
      final currentEpisode = selectEpisode.value;
      if (currentEpisode != null) {
        final episodeIndex = episodeList.indexOf(currentEpisode);
        if (episodeIndex != -1 && episodeIndex < episodeList.length - 1) {
          // 不是最后一集,播放下一集
          mediaPlayerController.setRecrodAction(null);
          final nextEpisode = episodeList[episodeIndex + 1];
          chooseEpisode(nextEpisode);
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

    // Clear old data to prevent mixing data from previous media
    seasonList.clear();
    episodeList.clear();
    episodeListCache.clear();

    getDataFromServer();
  }

  /// 保存播放记录
  void saveMedia() {
    if (mediaPlayerController.mediaPlayerStatus.completed) {
      // 播放完成删除 缓存
      VideoCacheUtils.clearCache(
        videoType == VideoType.video ? mediaDetailEntity?.video ?? '' : selectEpisode.value?.video ?? '',
      );
    }

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
      season: videoType == VideoType.tv || videoType == VideoType.anime ? selectSeason.value : null,
      episode: videoType == VideoType.tv || videoType == VideoType.anime ? selectEpisode.value : null,
    );

    Storage.addViewedMedia(historyEntity);

    EventBusManager.instance.post(EventBusName.historyRefresh);
  }
}
