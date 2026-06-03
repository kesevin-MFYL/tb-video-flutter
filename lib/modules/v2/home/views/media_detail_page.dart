import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/modules/v2/home/widget/auto_scroll_episode_wrapper.dart';
import 'package:editvideo/modules/v2/home/widget/episode_horizontal_cell.dart';
import 'package:editvideo/modules/v2/home/widget/episode_vertical_cell.dart';
import 'package:editvideo/modules/v2/home/widget/media_player_view.dart';
import 'package:editvideo/modules/v2/home/widget/media_scroller_view.dart';
import 'package:editvideo/modules/v2/home/widget/tab_page_view.dart';
import 'package:editvideo/modules/v2/home/widget/tv_season_view.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/dialog/subtitle_settings_bottom_sheet.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:editvideo/widget/media/model/media_player_status.dart';
import 'package:editvideo/widget/media/utils/fullscreen.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 影片详情
class MediaDetailPage extends StatefulWidget {
  const MediaDetailPage({super.key, required this.mediaId});

  final int mediaId;

  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> with RouteAware, WidgetsBindingObserver {
  late MediaDetailController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = Get.put(MediaDetailController(), tag: '${widget.mediaId}');

    lifecycleListener();
    initPlayerStatusListener();
  }

  void initPlayerStatusListener() {
    controller.mediaPlayerController.addStatusLister(playerListener);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaDetailController>(
      tag: '${widget.mediaId}',
      builder: (controller) {
        return Obx(() {
          final isFullscreen = controller.mediaPlayerController.isFullScreen.value;
          return PopScope(
            canPop: !isFullscreen,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                controller.mediaPlayerController.triggerFullScreen(status: false);
                if (MediaQuery.of(context).orientation == Orientation.landscape) {
                  verticalScreen();
                }

                // 重置锁屏状态
                if (controller.mediaPlayerController.controlsLock.value) {
                  controller.mediaPlayerController.controlsLock.value = false;
                }
              }
            },
            child: Stack(
              children: [
                PageBase(
                  hasAppBar: false,
                  child: MultiStatusView(
                    currentStatus: controller.multiStatusType,
                    action: () {
                      controller.reload();
                    },
                    child: SafeArea(
                      top: isFullscreen ? false : true,
                      bottom: isFullscreen ? false : true,
                      child: ExtendedNestedScrollView(
                        headerSliverBuilder: (BuildContext context2, bool innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              pinned: true,
                              elevation: 0,
                              scrolledUnderElevation: 0,
                              forceElevated: innerBoxIsScrolled,
                              expandedHeight: isFullscreen ? Get.size.height : controller.videoHeight,
                              backgroundColor: Colors.black,
                              flexibleSpace: FlexibleSpaceBar(
                                background: Container(color: CommonColors.color333333, child: _buildMediaPlayerView()),
                              ),
                            ),
                          ];
                        },
                        pinnedHeaderSliverHeightBuilder: () {
                          return isFullscreen ? Get.size.height : controller.videoHeight;
                        },
                        onlyOneScrollInBody: true,
                        body: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(vertical: 8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 主要信息
                              _buildBasicInfo(),

                              // 电视剧剧集
                              _buildTvSeasons(),

                              // 其他信息
                              _buildOtherInfo(),

                              // 相关推荐
                              ..._buildRecommend(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: isFullscreen ? false : true,
                    maintainState: true,
                    child: _buildBottomOtherInfo(),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: isFullscreen ? false : true,
                    maintainState: true,
                    child: _buildBottomTvSeasons(),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: isFullscreen ? false : true,
                    maintainState: true,
                    child: _buildBottomSubtitleSettings(),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildMediaPlayerView() {
    return MediaPlayerView(
      key: ValueKey(controller.mediaId),
      mediaId: controller.mediaId,
      mediaPlayerController: controller.mediaPlayerController,
      mediaPlayerFuture: controller.mediaPlayerFuture,
      onReload: () {
        controller.mediaPlayerFuture = controller.initMediaPlayer();
        controller.update();
      },
      onChooseEpisode: controller.showRightTvSeasonsDialog,
      onShowSubtitleSettings: controller.showSubtitleSettingsDialog,
      onNextPlay: controller.nextPlay,
    );
  }

  Widget _buildBasicInfo({bool isBottomSheet = false}) {
    if (controller.mediaDetailEntity == null) return const SizedBox();
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 16.w, top: isBottomSheet ? 0 : 16.w, right: 16.w, bottom: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return CommonText.instance(
                    controller.mediaPlayerController.mediaTitle.value,
                    16.sp,
                    color: isBottomSheet ? CommonColors.white.withOpacity(0.8) : CommonColors.white,
                    fontWeight: CommonFontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ),
              if (isBottomSheet)
                CommonButton(
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: controller.bottomOtherInfoChanged,
                  child: Image.asset(Assets.commonIconBottomClose, width: 24.w, height: 24.w),
                ),
            ],
          ),

          Padding(
            padding: EdgeInsetsGeometry.only(top: isBottomSheet ? 9.w : 12.w, bottom: 12.w),
            child: Wrap(
              spacing: 8.w, // 标签之间的水平间距
              runSpacing: 8.h, // 标签之间的垂直间距
              children: [
                if (controller.mediaDetailEntity!.certification.isNotEmptyString())
                  _buildTag(tagName: controller.mediaDetailEntity!.certification!),
                if (controller.mediaDetailEntity!.country.isNotEmptyString())
                  _buildTag(tagName: controller.mediaDetailEntity!.country!),
                if (controller.mediaDetailEntity!.year.isNotEmptyString())
                  _buildTag(tagName: controller.mediaDetailEntity!.year!),
              ],
            ),
          ),

          if (controller.mediaDetailEntity!.genreList != null && controller.mediaDetailEntity!.genreList!.isNotEmpty)
            CommonText.instance(
              controller.mediaDetailEntity!.genreList!.join(' / '),
              12.sp,
              color: CommonColors.white.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildOtherInfo({bool isBottomSheet = false}) {
    if (controller.mediaDetailEntity == null) return const SizedBox();
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.commonIconMediaInfo, width: 24.w, height: 24.w),
              SizedBox(width: 8.w),
              CommonText.instance('INFO', 16.sp, fontWeight: CommonFontWeight.bold),
            ],
          ),
          SizedBox(height: 12.w),
          if (!isBottomSheet)
            Row(
              children: [
                Expanded(
                  child: CommonText.instance(
                    controller.mediaDetailEntity!.description ?? '',
                    14.sp,
                    color: CommonColors.white.withOpacity(0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                CommonButton(
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  spacing: 4.w,
                  suffixDirectional: SuffixDirectional.right,
                  suffixWidget: Image.asset(Assets.commonIconVideoArrowRight, width: 16.w, height: 16.w),
                  onPressed: () => controller.bottomOtherInfoChanged(),
                  child: CommonText.instance(
                    'View All',
                    12.sp,
                    color: CommonColors.primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: CommonColors.primaryColor,
                  ),
                ),
              ],
            )
          else
            CommonText.instance(
              controller.mediaDetailEntity!.description ?? '',
              14.sp,
              color: CommonColors.white.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  /// 其他信息底部弹窗
  Widget _buildBottomOtherInfo() {
    return Obx(() {
      final showBottomOtherInfo = controller.showBottomOtherInfo.value;
      return IgnorePointer(
        ignoring: !showBottomOtherInfo,
        child: ClipRect(
          child: TweenAnimationBuilder<Offset>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            tween: showBottomOtherInfo
                ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                : Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)),
            builder: (context, offset, child) {
              return FractionalTranslation(translation: offset, child: child);
            },
            child: Container(
              padding: EdgeInsets.only(top: 22.w, bottom: safeAreaBottomDistance(16.w)),
              height: controller.bottomHeight,
              decoration: BoxDecoration(
                color: CommonColors.color1B1B18,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.h), topRight: Radius.circular(32.h)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildBasicInfo(isBottomSheet: true), _buildCast(), _buildOtherInfo(isBottomSheet: true)],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 演员列表
  Widget _buildCast() {
    if (controller.mediaDetailEntity == null ||
        controller.mediaDetailEntity!.cast == null ||
        controller.mediaDetailEntity!.cast!.isEmpty) {
      return const SizedBox();
    }
    final castList = controller.mediaDetailEntity!.cast!;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: castList.map((entity) {
            final index = castList.indexOf(entity);
            return Container(
              constraints: BoxConstraints(maxWidth: 54.w),
              margin: EdgeInsets.only(right: index != castList.length - 1 ? 16.w : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonButton(
                    minSize: 54.w,
                    borderRadius: BorderRadius.circular(22.r),
                    color: CommonColors.color333333,
                    child: ClipOval(
                      child: CommonImageView.normal(imageUrl: entity.cover, width: 54.w, height: 54.w),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CommonText.instance(
                    entity.name ?? '--',
                    12.sp,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 剧集信息
  Widget _buildTvSeasons() {
    if (controller.videoType != VideoType.tv) return const SizedBox();

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 16.w),
      child: TvSeasonView(
        controller: controller,
        contentBuilder: (context, episodeList) {
          return AutoScrollEpisodeWrapper(
            controller: controller,
            episodeList: episodeList,
            calculateOffset: (index, viewportDimension) {
              final itemWidth = 48.w;
              final spacing = 8.w;
              final padding = 16.w;
              final itemCenter = padding + index * (itemWidth + spacing) + itemWidth / 2;
              return itemCenter - viewportDimension / 2;
            },
            builder: (context, scrollController) {
              return ListView.separated(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemCount: episodeList.length,
                itemBuilder: (context, index) {
                  final episodeItem = episodeList[index];
                  return Obx(() {
                    final selectEpisode = controller.selectEpisode.value;
                    return EpisodeHorizontalCell(
                      episodeEntity: episodeItem,
                      selected: selectEpisode == episodeItem,
                      action: controller.chooseEpisode,
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  /// 剧集底部弹窗
  Widget _buildBottomTvSeasons() {
    if (controller.videoType != VideoType.tv) return const SizedBox();

    return Obx(() {
      final showBottomSeasons = controller.showBottomSeasons.value;
      return IgnorePointer(
        ignoring: !showBottomSeasons,
        child: ClipRect(
          child: TweenAnimationBuilder<Offset>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            tween: showBottomSeasons
                ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                : Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)),
            builder: (context, offset, child) {
              return FractionalTranslation(translation: offset, child: child);
            },
            child: Container(
              padding: EdgeInsets.only(top: 22.w, bottom: safeAreaBottomDistance(16.w)),
              height: controller.bottomHeight,
              decoration: BoxDecoration(
                color: CommonColors.color1B1B18,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.h), topRight: Radius.circular(32.h)),
              ),
              child: TvSeasonView(
                controller: controller,
                isDialog: true,
                contentBuilder: (context, episodeList) {
                  return AutoScrollEpisodeWrapper(
                    controller: controller,
                    episodeList: episodeList,
                    calculateOffset: (index, viewportDimension) {
                      final itemHeight = 48.w;
                      final spacing = 16.w;
                      final padding = 16.w;
                      final itemCenter = padding + index * (itemHeight + spacing) + itemHeight / 2;
                      return itemCenter - viewportDimension / 2;
                    },
                    builder: (context, scrollController) {
                      return ListView.separated(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => SizedBox(height: 16.w),
                        itemCount: episodeList.length,
                        itemBuilder: (context, index) {
                          final episodeItem = episodeList[index];
                          return Obx(() {
                            final selectEpisode = controller.selectEpisode.value;
                            return EpisodeVerticalCell(
                              episodeEntity: episodeItem,
                              selected: selectEpisode == episodeItem,
                              action: controller.chooseEpisode,
                            );
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 字幕底部弹窗
  Widget _buildBottomSubtitleSettings() {
    return Obx(() {
      final showBottomSubtitleSettings = controller.showBottomSubtitleSettings.value;
      return IgnorePointer(
        ignoring: !showBottomSubtitleSettings,
        child: ClipRect(
          child: TweenAnimationBuilder<Offset>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            tween: showBottomSubtitleSettings
                ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                : Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)),
            builder: (context, offset, child) {
              return FractionalTranslation(translation: offset, child: child);
            },
            child: Container(
              padding: EdgeInsets.only(top: 22.w, bottom: safeAreaBottomDistance(16.w)),
              height: controller.bottomHeight,
              decoration: BoxDecoration(
                color: CommonColors.color1B1B18,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.h), topRight: Radius.circular(32.h)),
              ),
              child: SubtitleSettingsView(
                controller: controller.mediaPlayerController,
                onClose: controller.bottomSubtitleSettingsChanged,
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 推荐
  List<Widget> _buildRecommend() {
    return controller.recommendList.map((section) {
      final sectionType = SectionType.kind(section.kind);
      return _buildRecommendSection(sectionType: sectionType, section: section);
    }).toList();
  }

  Widget _buildRecommendSection({required SectionType sectionType, required HomeSectionEntity section}) {
    if (section.dataList == null || section.dataList!.isEmpty == true) {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: buildEmojiAlignedText(
              section?.title ?? '',
              style: CommonTextStyle.instance(14.sp, fontWeight: CommonFontWeight.bold),
            ),
          ),

          SizedBox(height: 12.w),
          _buildSubSection(sectionType: sectionType, section: section),
        ],
      ),
    );
  }

  Widget _buildSubSection({required SectionType sectionType, required HomeSectionEntity section}) {
    switch (sectionType) {
      case SectionType.imdbList: //合集list
      case SectionType.mediaList: //单片
      case SectionType.imdbInterest: //兴趣分类
        return _buildHorizontalList(sectionType: sectionType, section: section);
      case SectionType.streamingMedia: //渠道
        return _buildStreamingMedia(section: section);
      default:
        return const SizedBox();
    }
  }

  Widget _buildHorizontalList({required SectionType sectionType, required HomeSectionEntity section}) {
    final dataList = section.dataList ?? [];

    return MediaScrollerView(mediaList: dataList, sectionType: sectionType, action: controller.mediaTap);
  }

  Widget _buildStreamingMedia({HomeSectionEntity? section}) {
    final tabBarViewHeight =
        165.w +
        12.w +
        2.w +
        'Text'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.medium)).height;

    final dataList = section?.dataList ?? [];
    return dataList.isEmpty
        ? const SizedBox()
        : TabPageView(mediaList: dataList, tabBarViewHeight: tabBarViewHeight, action: controller.mediaTap);
  }

  _buildTag({required String tagName}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: CommonColors.color84705C.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CommonText.instance(
        tagName,
        12.sp,
        color: CommonColors.white.withOpacity(0.8),
        fontWeight: CommonFontWeight.medium,
      ),
    );
  }

  // 播放器状态监听
  void playerListener(MediaPlayerStatusType status) async {
    if (status == MediaPlayerStatusType.completed) {
      // 全屏的情况下，结束播放退出全屏
      if (controller.mediaPlayerController.isFullScreen.value) {
        // 非锁定的情况下，退出全屏
        if (!controller.mediaPlayerController.controlsLock.value) {
          if (controller.isSideSeasonsDialogOpen || controller.isSubtitleSettingsDialogOpen) {
            Get.back();
          }
          controller.mediaPlayerController.triggerFullScreen(status: false);
        }
      }

      // 自动播放下一个内容
      controller.nextPlay();
    }
  }

  @override
  // 离开当前页面时
  void didPushNext() async {
    /// 开启
    controller.mediaPlayerController.removeStatusLister(playerListener);
    controller.mediaPlayerController.pause();
    // controller.mediaPlayerController.clearSubtitleContent();
    super.didPushNext();
  }

  @override
  // 返回当前页面时
  void didPopNext() async {
    // if (plPlayerController != null && plPlayerController!.videoPlayerController != null) {
    //   vdCtr.setSubtitleContent();
    //   isShowing.value = true;
    // }
    await Future.delayed(const Duration(milliseconds: 300));
    controller.mediaPlayerController.addStatusLister(playerListener);
    controller.mediaPlayerController.play();
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MediaDetailPage.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  // 生命周期监听
  void lifecycleListener() {
    // _lifecycleListener = AppLifecycleListener(
    //   // onResume: () => _handleTransition('resume'),
    //   // 后台
    //   // onInactive: () => _handleTransition('inactive'),
    //   // 在Android和iOS端不生效
    //   // onHide: () => _handleTransition('hide'),
    //   onShow: () => _handleTransition('show'),
    //   onPause: () => _handleTransition('pause'),
    //   onRestart: () => _handleTransition('restart'),
    //   onDetach: () => _handleTransition('detach'),
    // );
  }
}
