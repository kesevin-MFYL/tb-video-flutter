import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/common_api.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/caption_entity.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_detail_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/dialog/subtitle_setting_dialog.dart';
import 'package:editvideo/widget/dialog/tv_season_dialog.dart';
import 'package:editvideo/widget/media/media_player_controller.dart';
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class MediaDetailController extends BaseController with GetSingleTickerProviderStateMixin {
  /// 详情状态
  var multiStatusType = MultiStatusType.statusLoading;

  /// 集列表状态
  var episodeStatusType = MultiStatusType.statusLoading.obs;

  var firstLoad = true;

  /// 媒体id
  late int mediaId;

  /// 媒体类型
  late int mediaType;

  late VideoType videoType;

  /// 缓存记录
  MediaHistoryEntity? mediaHistoryEntity;

  MediaDetailEntity? mediaDetailEntity;

  var videoUrl = '';

  var recommendList = <HomeSectionEntity>[];

  TabController? tabController;

  /// 季列表
  var seasonList = <SeasonEntity>[];

  /// 集列表
  var episodeList = <EpisodeEntity>[];

  /// 缓存各季的集列表
  final Map<int, List<EpisodeEntity>> _episodeListCache = {};

  var captionList = <CaptionEntity>[];

  /// 选中的季
  final selectSeason = Rx<SeasonEntity?>(null);

  /// 选中的集
  final selectEpisode = Rx<EpisodeEntity?>(null);

  /// 是否显示媒体详情弹窗
  var showBottomOtherInfo = false.obs;

  /// 是否显示剧集底部弹窗
  var showBottomSeasons = false.obs;

  /// 是否显示字幕底部弹窗
  var showBottomSubtitleSettings = false.obs;

  bool isSideSeasonsDialogOpen = false;
  bool isSubtitleSettingsDialogOpen = false;

  double get bottomHeight => Get.height - safeAreaEdgeInsets.top - videoHeight;

  double get videoHeight => Get.width * 9 / 16;

  bool get isFullscreen => mediaPlayerController.isFullScreen.value || MediaQuery.of(Get.context!).orientation == Orientation.landscape;

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
    mediaPlayerController.submitVideoAction = submitViewVideo;
    mediaPlayerController.getNextVideoUrlAction = getNextVideoUrl;
  }

  Future<String?> getNextVideoUrl() async {
    if (videoType == VideoType.video) {
      if (recommendList.isNotEmpty) {
        MediaItemEntity? firstRecommendItem;
        final homeSectionItem = recommendList.firstWhereOrNull((element) {
          final sectionType = SectionType.kind(element.kind);
          return sectionType == SectionType.mediaList;
        });
        if (homeSectionItem != null && homeSectionItem.dataList != null && homeSectionItem.dataList!.isNotEmpty) {
          firstRecommendItem = homeSectionItem.dataList!.first;
        }
        if (firstRecommendItem != null) {
          final result = await HomeApi.getMediaDetail(id: firstRecommendItem.id ?? 0);
          if (result.isSuccess) {
            return result.responseData?.data?.video;
          }
        }
      }
      return null;
    } else if (videoType == VideoType.tv) {
      final currentSeason = selectSeason.value;
      final currentEpisode = selectEpisode.value;
      if (currentSeason != null && currentEpisode != null) {
        final episodeIndex = episodeList.indexOf(currentEpisode);
        final seasonIndex = seasonList.indexOf(currentSeason);
        if (episodeIndex != -1 && episodeIndex < episodeList.length - 1) {
          return episodeList[episodeIndex + 1].video;
        } else if (episodeIndex != -1 && episodeIndex == episodeList.length - 1) {
          if (seasonIndex != -1 && seasonIndex < seasonList.length - 1) {
            final nextSeason = seasonList[seasonIndex + 1];
            if (_episodeListCache.containsKey(nextSeason.id)) {
              final nextEpisodeList = _episodeListCache[nextSeason.id]!;
              if (nextEpisodeList.isNotEmpty) {
                return nextEpisodeList.first.video;
              }
            } else {
              final result = await HomeApi.getSeasonAllEpisodes(id: nextSeason.id);
              if (result.isSuccess) {
                final listData = result.responseData?.data ?? [];
                _episodeListCache[nextSeason.id!] = listData;
                if (listData.isNotEmpty) {
                  return listData.first.video;
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  @override
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() {
    Future.wait([_getMediaDetail(), _getMediaRecommend(), _getTvSeasons()]).then((list) {
      changeFutureAndTitle();
      firstLoad = false;
      EasyLoading.dismiss();
    });
  }

  /// 重置播放器和修改标题
  void changeFutureAndTitle() {
    openMediaData();
    changeTitle();
    update();
  }

  /// 改变标题
  void changeTitle() {
    mediaPlayerController.changeMediaTitle(
      videoType == VideoType.video
          ? mediaDetailEntity?.title ?? ''
          : '${selectEpisode.value?.epsNum ?? 0} ${mediaDetailEntity?.title ?? ''} ${selectSeason.value?.title ?? ''}',
    );
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

    changeFutureAndTitle();
  }

  /// 获取媒体详情
  Future<void> _getMediaDetail() async {
    final result = await HomeApi.getMediaDetail(id: mediaId);
    if (result.isSuccess) {
      mediaDetailEntity = result.responseData?.data;

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

      if (tabController == null) {
        var initialIndex = 0;

        if (mediaHistoryEntity != null) {
          // 有缓存记录
          selectSeason.value = mediaHistoryEntity?.season;
          final seasonId = selectSeason.value?.id ?? 0;
          initialIndex = seasonList.indexWhere((element) => element.id == seasonId);
        } else {
          // 没有历史记录默认第一季
          selectSeason.value = seasonList.first;
        }

        tabController ??= TabController(initialIndex: initialIndex, length: seasonList.length, vsync: this);
      }

      // 获取季下的所有集
      await _getEpisodeList(seasonId: selectSeason.value?.id);
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  /// 获取季下的所有集
  Future<void> _getEpisodeList({int? seasonId, bool nextPlay = false}) async {
    if (selectSeason.value == null) return;

    final targetSeasonId = seasonId ?? selectSeason.value?.id;
    if (targetSeasonId == null) return;

    if (_episodeListCache.containsKey(targetSeasonId)) {
      episodeList = _episodeListCache[targetSeasonId]!;
      _handleEpisodeListSuccess(nextPlay: nextPlay);
      return;
    }

    final result = await HomeApi.getSeasonAllEpisodes(id: targetSeasonId);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      episodeList = listData ?? [];
      _episodeListCache[targetSeasonId] = episodeList;

      _handleEpisodeListSuccess(nextPlay: nextPlay);
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      episodeStatusType.value = MultiStatusType.statusError;
    }
  }

  void _handleEpisodeListSuccess({bool nextPlay = false}) {
    if (firstLoad) {
      if (mediaHistoryEntity != null) {
        // 有缓存记录
        selectEpisode.value = episodeList.firstWhereOrNull((element) => element.id == mediaHistoryEntity!.episode?.id);
      } else {
        // 没有缓存记录默认第一集
        if (episodeList.isNotEmpty) {
          selectEpisode.value = episodeList.first;
        }
      }

      // 检查是否有下一集
      checkHasNextPlay();

      captionList = selectEpisode.value?.captionList ?? [];
    }

    if (nextPlay) {
      if (episodeList.isNotEmpty) {
        selectEpisode.value = episodeList.first;
      }
    }

    episodeStatusType.value = episodeList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;

    EasyLoading.dismiss();
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

  /// 季Tab切换
  void seasonTabChanged(int tabIndex) {
    episodeStatusType.value = MultiStatusType.statusLoading;
    _getEpisodeList(seasonId: seasonList[tabIndex].id);
  }

  /// 重新获取剧集
  void reloadEpisodeList() {
    if (tabController!.index >= seasonList.length) return;

    _getEpisodeList(seasonId: seasonList[tabController!.index].id);
  }

  /// 信息弹窗(竖屏)
  void bottomOtherInfoChanged() {
    showBottomOtherInfo.value = !showBottomOtherInfo.value;
  }

  /// 剧集弹窗(竖屏)
  void bottomSeasonsChanged() {
    showBottomSeasons.value = !showBottomSeasons.value;
  }

  /// 字幕弹窗(竖屏)
  void bottomSubtitleSettingsChanged() {
    showBottomSubtitleSettings.value = !showBottomSubtitleSettings.value;
  }

  void closeBottomSheet() {
    if (showBottomSeasons.value) {
      showBottomSeasons.value = false;
    }
    if (showBottomOtherInfo.value) {
      showBottomOtherInfo.value = false;
    }
    if (showBottomSubtitleSettings.value) {
      showBottomSubtitleSettings.value = false;
    }
  }

  /// 剧集右侧弹窗(横屏)
  void showRightTvSeasonsDialog() {
    if (videoType != VideoType.tv) return;

    isSideSeasonsDialogOpen = true;
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierLabel: 'SideSeasons',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TvSeasonDialog(controller: this);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    ).then((_) {
      isSideSeasonsDialogOpen = false;
    });
  }

  /// 字幕右侧弹窗(横屏)/底部弹窗(竖屏)
  void showSubtitleSettingsDialog() {
    if (isFullscreen) {
      isSubtitleSettingsDialogOpen = true;
      showGeneralDialog(
        context: Get.context!,
        barrierDismissible: true,
        barrierLabel: 'SubtitleSettings',
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return SubtitleSettingsDialog(controller: mediaPlayerController);
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ).then((_) {
        isSubtitleSettingsDialogOpen = false;
      });
    } else {
      bottomSubtitleSettingsChanged();
    }
  }

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
          EasyLoading.show();
          mediaId = firstRecommendItem.id ?? 0;
          mediaType = firstRecommendItem.type ?? 1;
          videoType = VideoType.instance(mediaType);
          // await mediaPlayerController.resetSubtitle();
          mediaPlayerController.setRecrodAction(null);
          getDataFromServer();
        } else {
          mediaPlayerController.showControls.value = true;
        }
      } else {
        mediaPlayerController.showControls.value = true;
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
          // await mediaPlayerController.resetSubtitle();
          mediaPlayerController.setRecrodAction(null);
          final nextEpisode = episodeList[episodeIndex + 1];
          chooseEpisode(nextEpisode);
        } else if (episodeIndex != -1 && episodeIndex == episodeList.length - 1) {
          // 最后一集
          if (seasonIndex != -1 && seasonIndex < seasonList.length - 1) {
            // 不是最后一季
            // 播放下一季第一集
            EasyLoading.show();
            // await mediaPlayerController.resetSubtitle();
            mediaPlayerController.setRecrodAction(null);
            final nextSeason = seasonList[seasonIndex + 1];
            selectSeason.value = nextSeason;
            await _getEpisodeList(seasonId: selectSeason.value?.id, nextPlay: true);
            tabController?.animateTo(seasonIndex + 1);
            chooseEpisode(selectEpisode.value!);
          } else if (seasonIndex != -1 && seasonIndex == seasonList.length - 1) {
            // 是最后一季
            mediaPlayerController.showControls.value = true;
          }
        }
      } else {
        mediaPlayerController.showControls.value = true;
      }
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
    Get.toNamed(
      Routes.mediaDetailPage,
      arguments: {'mediaId': mediaItemEntity.id, 'mediaType': mediaItemEntity.type},
      preventDuplicates: false,
    );
  }

  void saveMedia() {
    if (mediaPlayerController.mediaPlayerStatus.completed) {
      // 播放完成删除
      Storage.deleteViewedMediaById(mediaDetailEntity?.id ?? 0);
    } else {
      //Save history with new entity
      final historyEntity = MediaHistoryEntity(
        id: mediaDetailEntity?.id,
        title: mediaDetailEntity?.title,
        cover: mediaDetailEntity?.cover,
        type: mediaType,
        videoUrl: videoUrl,
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

  /// 提交已看过影视到IMDB
  void submitViewVideo() async {
    if (mediaDetailEntity == null || mediaDetailEntity!.imdbId.isEmptyString()) return;

    final result = await CommonApi.submitViewVideo(imdbId: mediaDetailEntity!.imdbId!);
    if (result.isSuccess) {
      final hasPlayVideo = Storage.getHasPlayVideo() ?? false;
      if (!hasPlayVideo) {
        // 记录用户行为
        Storage.setHasPlayVideo(true);
      }
    }
  }

  void openMediaData({bool isReload = false}) async {
    try {
      videoUrl = videoType == VideoType.video ? mediaDetailEntity?.video ?? '' : selectEpisode.value?.video ?? '';

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

  @override
  void onClose() {
    mediaPlayerController.dispose();
    tabController?.dispose();
    super.onClose();
  }
}
