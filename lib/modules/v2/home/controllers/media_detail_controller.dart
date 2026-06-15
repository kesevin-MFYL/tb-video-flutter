import 'package:editvideo/config/network/api/common_api.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/base_media_detail_controller.dart';
import 'package:editvideo/modules/v2/home/widget/dialog/tv_season_dialog.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/modules/v2/home/widget/dialog/subtitle_setting_dialog.dart';
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 影片详情
class MediaDetailController extends BaseMediaDetailController {
  double get bottomHeight => Get.height - safeAreaEdgeInsets.top - videoHeight;

  double get videoHeight => Get.width * 9 / 16;

  bool get isFullscreen =>
      mediaPlayerController.isFullScreen.value || mediaPlayerController.currentOrientation.value == Orientation.landscape;

  /// 是否显示媒体详情弹窗
  var showBottomOtherInfo = false.obs;

  /// 是否显示剧集底部弹窗
  var showBottomSeasons = false.obs;

  /// 是否显示字幕底部弹窗
  var showBottomSubtitleSettings = false.obs;

  /// 横屏选集dialog
  bool isSideSeasonsDialogOpen = false;

  /// 横屏字幕设置dialog
  bool isSubtitleSettingsDialogOpen = false;

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

  /// 关闭所有底部弹窗
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

  void reload() {
    multiStatusType = MultiStatusType.statusLoading;
    update();
    getDataFromServer();
  }

  @override
  void handRegister() {
    mediaPlayerController.submitVideoAction = submitViewVideo;
    mediaPlayerController.getNextVideoUrlAction = getNextVideoUrl;
    mediaPlayerController.checkHasNextPlayAction = checkHasNextPlay;
  }

  /// 获取下一个视频地址
  Future<String?> getNextVideoUrl() async {
    if (videoType == VideoType.video) {
      // 如果是影片
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
      // 如果是电视剧
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
            if (episodeListCache.containsKey(nextSeason.id)) {
              final nextEpisodeList = episodeListCache[nextSeason.id]!;
              if (nextEpisodeList.isNotEmpty) {
                return nextEpisodeList.first.video;
              }
            } else {
              final result = await HomeApi.getSeasonAllEpisodes(id: nextSeason.id);
              if (result.isSuccess) {
                final listData = result.responseData?.data ?? [];
                episodeListCache[nextSeason.id!] = listData;
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

  /// 检查是否有下一集
  bool checkHasNextPlay() {
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
        return false;
      } else {
        return true;
      }
    }
    return true;
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

  /// 重新获取剧集
  void reloadEpisodeList() {
    if (tabController!.index >= seasonList.length) return;
    if (isMultiOpen) {
      episodeStatusType.value = MultiStatusType.statusLoading;
      getEpisodeList(seasonId: seasonList[tabController!.index].id);
    } else {
      final seasonId = seasonList[tabController!.index].id;
      episodeList = episodeListCache[seasonId] ?? [];
      update();
    }
  }

  void mediaTap(MediaItemEntity mediaItem, SectionType sectionType) {
    if (sectionType == SectionType.mediaList || sectionType == SectionType.topPicks) {
      // 单片，进入视频播放页
      // toMediaDetail(mediaItem);
      if (isMultiOpen) {
        toMediaDetailMultiPage(mediaId: mediaItem.id, mediaType: mediaItem.type);
      } else {
        toMediaDetailSinglePage(mediaId: mediaItem.id, mediaType: mediaItem.type);
      }
    } else if (sectionType == SectionType.imdbList) {
      // 合集，进入合集二级页
      Get.toNamed(Routes.imdbListSubPage, arguments: mediaItem);
    } else if (sectionType == SectionType.imdbInterest) {
      // 进入分类详情页
      Get.toNamed(Routes.interestDetailPage, arguments: mediaItem);
    } else if (sectionType == SectionType.streamingMedia) {
      // 渠道，进入视频播放页
      // toMediaDetail(mediaItem);
      if (isMultiOpen) {
        toMediaDetailMultiPage(mediaId: mediaItem.id, mediaType: mediaItem.type);
      } else {
        toMediaDetailSinglePage(mediaId: mediaItem.id, mediaType: mediaItem.type);
      }
    }
  }

  @override
  void onClose() {
    mediaPlayerController.dispose();
    tabController?.dispose();
    super.onClose();
  }
}
