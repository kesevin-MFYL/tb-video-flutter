import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/media/model/media_data_source.dart';
import 'package:editvideo/widget/media/utils/string_utils.dart';
import 'package:editvideo/widget/media/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// 播放器控制面板
class VideoPlayerControlPanel extends StatefulWidget {
  const VideoPlayerControlPanel(
    this.controller, {
    super.key,
    required this.onToggleFullScreen,
    this.onChooseEpisode,
    this.onShowSubtitleSettings,
    this.onNextPlay,
    this.onReload,
    this.onBackAction,
  });

  final PlayerController controller;
  final ValueChanged<bool> onToggleFullScreen;
  final VoidCallback? onReload;
  final VoidCallback? onChooseEpisode;
  final VoidCallback? onShowSubtitleSettings;
  final VoidCallback? onNextPlay;
  final VoidCallback? onBackAction;

  @override
  State<VideoPlayerControlPanel> createState() => _VideoPlayerControlPanelState();
}

class _VideoPlayerControlPanelState extends State<VideoPlayerControlPanel> {
  late PlayerController mediaPlayerController;

  late double screenWidth;

  /// 亮度
  final _brightnessValue = 0.0.obs;
  final _brightnessPopShow = false.obs;
  Timer? _brightnessTimer;

  /// 音量
  final _volumeValue = 0.0.obs;
  final _volumePopShow = false.obs;
  final _volumeInterceptEventStream = false.obs;
  Timer? _volumeTimer;

  double tempSpeed = 1.0;
  Duration? tempSliderPosition;

  bool get isFullscreen => mediaPlayerController.isFullscreen;

  @override
  void initState() {
    super.initState();
    mediaPlayerController = widget.controller;
    screenWidth = Get.size.width;
    _initVolumeAndBrightness();
  }

  /// 初始化音量、亮度
  void _initVolumeAndBrightness() {
    Future.microtask(() async {
      try {
        FlutterVolumeController.updateShowSystemUI(true);
        final vol = await FlutterVolumeController.getVolume();
        _volumeValue.value = vol ?? 0.0;
        FlutterVolumeController.addListener((double value) {
          if (mounted && !_volumeInterceptEventStream.value) {
            _volumeValue.value = value;
          }
        });
      } catch (_) {}
    });

    Future.microtask(() async {
      try {
        _brightnessValue.value = await ScreenBrightness().current;
        ScreenBrightness().onCurrentBrightnessChanged.listen((double value) {
          if (mounted) {
            _brightnessValue.value = value;
          }
        });
      } catch (_) {}
    });
  }

  /// 设置音量
  Future<void> setVolume(double value) async {
    try {
      FlutterVolumeController.updateShowSystemUI(false);
      await FlutterVolumeController.setVolume(value);
    } catch (_) {}
    _volumeValue.value = value;
    _volumePopShow.value = true;
    _volumeInterceptEventStream.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _volumePopShow.value = false;
        _volumeInterceptEventStream.value = false;
      }
    });
  }

  /// 设置亮度
  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightness().setScreenBrightness(value);
    } catch (_) {}
    _brightnessPopShow.value = true;
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        _brightnessPopShow.value = false;
      }
    });
    mediaPlayerController.currentBrightness = value;
  }

  @override
  void dispose() {
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 手势识别层
        GestureDetector(
          onTap: () {
            // 切换操作栏状态
            mediaPlayerController.toggleControls();
          },
          onDoubleTap: () {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            // 双击切换播放状态
            mediaPlayerController.togglePlay();
          },
          onLongPress: () {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            mediaPlayerController.longPressStatus.value = true;
            tempSpeed = mediaPlayerController.defaultSpeed;
            //长按2倍速度
            mediaPlayerController.setPlaybackSpeed(tempSpeed * 2);
          },
          onLongPressEnd: (details) {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            mediaPlayerController.longPressStatus.value = false;
            //长按结束时恢复本来的速度
            mediaPlayerController.setPlaybackSpeed(tempSpeed);
          },
          onHorizontalDragStart: (details) {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            tempSliderPosition = mediaPlayerController.currentPosition.value;
          },
          onHorizontalDragUpdate: (details) {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            final int curSliderPosition = mediaPlayerController.sliderPosition.value.inMilliseconds;
            final double scale = 90000 / MediaQuery.sizeOf(context).width;
            final Duration pos = Duration(milliseconds: curSliderPosition + (details.delta.dx * scale).round());

            int resultMs = pos.inMilliseconds;
            int maxMs = mediaPlayerController.totalDuration.value.inMilliseconds;
            if (resultMs < 0) resultMs = 0;
            if (resultMs > maxMs) resultMs = maxMs;
            final Duration result = Duration(milliseconds: resultMs);

            mediaPlayerController.sliderPosition.value = result;
            mediaPlayerController.isSliderMoving.value = true;
            mediaPlayerController.seekPreview(result);
          },
          onHorizontalDragEnd: (details) {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            mediaPlayerController.isSliderMoving.value = false;
            mediaPlayerController.seekTo(mediaPlayerController.sliderPosition.value, isHorizontalMove: true);
            mediaPlayerController.play();
          },
          onVerticalDragUpdate: (DragUpdateDetails details) async {
            // 数据加载中或错误 禁用
            if (!mediaPlayerController.isInitialized.value || mediaPlayerController.hasError.value) return;

            final double totalWidth = MediaQuery.sizeOf(context).width;
            final double tapPosition = details.localPosition.dx;
            final double sectionWidth = totalWidth / 2;
            final double delta = details.delta.dy;

            // 锁定时🔒禁用
            if (mediaPlayerController.controlsLock.value) {
              return;
            }

            if (tapPosition < sectionWidth) {
              // 左边区域 👈
              final double level = (isFullscreen ? Get.size.height : screenWidth * 9 / 16) * 3;
              if (level > 0) {
                final double brightness = _brightnessValue.value - (delta / level);
                final double result = brightness.clamp(0.0, 1.0);
                setBrightness(result);
              }
            } else {
              final double level = (isFullscreen ? Get.size.height : screenWidth * 9 / 16);
              if (level > 0) {
                final double volume = _volumeValue.value - (delta / level);
                final double result = volume.clamp(0.0, 1.0);
                setVolume(result);
              }
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {},
        ),

        // 字幕
        Obx(() {
          final isFullScreen = isFullscreen;
          final openCaptions = mediaPlayerController.openCaptions.value;
          final subTitle = mediaPlayerController.subTitle.value;
          final showControls = mediaPlayerController.showControls.value;

          final isMultiLine = subTitle.contains('\n');
          double bottomPadding = 16.0;

          if (isFullScreen) {
            if (isMultiLine) {
              bottomPadding = showControls ? 55.0 : 16.0;
            } else {
              bottomPadding = showControls ? 67.0 : 28.0;
            }
          } else {
            if (isMultiLine) {
              bottomPadding = showControls ? 40.0 : 8.0;
            } else {
              bottomPadding = showControls ? 48.0 : 16.0;
            }
          }

          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: true,
              child: Visibility(
                visible: openCaptions,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isFullScreen ? 56 : 20,
                    right: isFullScreen ? 56 : 20,
                    bottom: bottomPadding,
                  ),
                  child: CommonText.instance(
                    subTitle,
                    isFullScreen ? 16 : 12,
                    color: CommonColors.white.withOpacity(0.9),
                    strutStyle: StrutStyle(forceStrutHeight: true, height: isFullScreen ? 1.3 : 1.1, leading: 0),
                    textAlign: TextAlign.center,
                    fontWeight: CommonFontWeight.medium,
                  ),
                ),
              ),
            ),
          );
        }),

        // 数据加载错误或缓存中
        Obx(() {
          if (mediaPlayerController.hasError.value) {
            return Container(
              color: CommonColors.color333333,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFullscreen) Image.asset(Assets.commonIconFullscreenEmpty, width: 160, height: 160),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: CommonText.instance(
                        'Sorry, the video cannot be played.Hopeyou can tell us, thank you!',
                        14,
                        color: CommonColors.white.withOpacity(0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 16),

                    CommonButton(
                      minSize: 32,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      borderRadius: BorderRadius.circular(20.r),
                      color: CommonColors.primaryColor,
                      onPressed: () {
                        widget.onReload?.call();
                      },
                      child: CommonText.instance(
                        'Reload',
                        14,
                        color: CommonColors.color060600,
                        fontWeight: CommonFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (mediaPlayerController.isBuffering.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  loadingIndicator(size: 30, strokeWidth: 2),
                  SizedBox(height: 6),
                  CommonText.instance('loading....', 12),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        }),

        // 操作面板
        Obx(() {
          final showControls = mediaPlayerController.showControls.value;
          final isFullScreen = isFullscreen;
          final isSliderMoving = mediaPlayerController.isSliderMoving.value;
          final isPlaying = mediaPlayerController.mediaPlayerStatus.playing;
          final currentPostion = mediaPlayerController.currentPosition.value;
          final totalDuration = mediaPlayerController.totalDuration.value;
          final sliderPosition = mediaPlayerController.sliderPosition.value;
          final bufferedDuration = mediaPlayerController.bufferedDuration.value;
          final isLocked = mediaPlayerController.controlsLock.value;
          final mediaTitle = mediaPlayerController.mediaTitle.value;
          final videoType = mediaPlayerController.videoType.value;
          final openCaptions = mediaPlayerController.openCaptions.value;

          return AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !showControls,
              child: Stack(
                children: [
                  // 蒙层
                  if (isFullScreen)
                    Positioned.fill(
                      child: IgnorePointer(child: Container(color: CommonColors.black.withOpacity(0.3))),
                    ),

                  // 锁
                  if (isFullScreen)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 60),
                        child: GestureDetector(
                          onTap: () {
                            mediaPlayerController.controlsLock.value = !isLocked;
                          },
                          child: Image.asset(
                            isLocked ? Assets.commonIconVideoLocked : Assets.commonIconVideoUnlock,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),

                  if (!isLocked) ...[
                    // 顶部操作栏
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isFullScreen ? 56 : 16,
                          vertical: isFullScreen ? 16 : 10,
                        ),
                        decoration: isFullScreen
                            ? null
                            : BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, CommonColors.color060600.withOpacity(0.8)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isFullScreen) {
                                  mediaPlayerController.triggerFullScreen(status: false);
                                } else {
                                  widget.onBackAction?.call();
                                }
                              },
                              child: Image.asset(Assets.commonNavBack, width: 32, height: 32),
                            ),

                            if (isFullScreen)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8, right: 24),
                                  child: CommonText.instance(
                                    mediaTitle,
                                    16,
                                    fontWeight: CommonFontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            else
                              Spacer(),

                            if (isFullScreen && videoType != VideoType.video)
                              Padding(
                                padding: EdgeInsets.only(right: 24),
                                child: GestureDetector(
                                  onTap: () => widget.onChooseEpisode?.call(),
                                  child: Image.asset(Assets.commonIconVideoChooseEpisode, width: 24, height: 24),
                                ),
                              ),

                            GestureDetector(
                              onTap: () {
                                if (!openCaptions && mediaPlayerController.captionList.isEmpty) {
                                  EasyLoading.showToast('Subtitles not available for this video.');
                                  return;
                                }
                                widget.onShowSubtitleSettings?.call();
                              },
                              child: Image.asset(
                                openCaptions ? Assets.commonIconSubtitleOpen : Assets.commonIconSubtitleClose,
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 播放/暂停按钮 滑动中不显示
                    Center(
                      child: !isSliderMoving
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: mediaPlayerController.fastRewind,
                                  child: Image.asset(
                                    Assets.commonIconVideoRewind,
                                    width: isFullScreen ? 40 : 32,
                                    height: isFullScreen ? 40 : 32,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: isFullScreen ? 88 : 66),
                                GestureDetector(
                                  onTap: mediaPlayerController.togglePlay,
                                  child: Image.asset(
                                    isPlaying ? Assets.commonVideoPause : Assets.commonVideoPlayBig,
                                    width: isFullScreen ? 64 : 48,
                                    height: isFullScreen ? 64 : 48,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: isFullScreen ? 88 : 66),
                                GestureDetector(
                                  onTap: mediaPlayerController.fastForward,
                                  child: Image.asset(
                                    Assets.commonIconVideoForward,
                                    width: isFullScreen ? 40 : 32,
                                    height: isFullScreen ? 40 : 32,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ),

                    // 底部操作栏
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isFullScreen ? 56 : 16,
                          vertical: isFullScreen ? 16 : 8,
                        ),
                        decoration: isFullScreen
                            ? null
                            : BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, CommonColors.color060600.withOpacity(0.8)],
                                ),
                              ),
                        child: Row(
                          children: [
                            // 播放/暂停按钮
                            GestureDetector(
                              onTap: mediaPlayerController.togglePlay,
                              child: Image.asset(
                                isPlaying ? Assets.commonIconPause : Assets.commonIconPlay,
                                width: isFullScreen ? 32 : 24,
                                height: isFullScreen ? 32 : 24,
                                fit: BoxFit.cover,
                              ),
                            ),

                            if (isFullScreen && videoType != VideoType.video)
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Obx(() {
                                  final hasNext = mediaPlayerController.hasNextEpisode.value;
                                  return GestureDetector(
                                    onTap: hasNext
                                        ? () {
                                            widget.onNextPlay?.call();
                                          }
                                        : null,
                                    child: Opacity(
                                      opacity: hasNext ? 1.0 : 0.5,
                                      child: Image.asset(Assets.commonIconVideoPlayNext, width: 32, height: 32),
                                    ),
                                  );
                                }),
                              ),

                            // 时长、进度条
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsGeometry.symmetric(horizontal: isFullScreen ? 16 : 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // 进度条
                                    ProgressBar(
                                      progress: Duration(seconds: sliderPosition.inSeconds),
                                      buffered: Duration(seconds: bufferedDuration.inSeconds),
                                      total: Duration(seconds: totalDuration.inSeconds),
                                      progressBarColor: CommonColors.colorDB88E6,
                                      baseBarColor: CommonColors.white.withOpacity(0.3),
                                      bufferedBarColor: CommonColors.colorDB88E6.withOpacity(0.4),
                                      timeLabelLocation: TimeLabelLocation.none,
                                      thumbColor: CommonColors.primaryColor,
                                      barHeight: 4,
                                      thumbRadius: 5,
                                      onDragStart: (duration) {
                                        if (!mediaPlayerController.isInitialized.value) return;
                                        tempSliderPosition = mediaPlayerController.currentPosition.value;
                                        mediaPlayerController.isSliderMoving.value = true;
                                      },
                                      onDragUpdate: (duration) {
                                        if (!mediaPlayerController.isInitialized.value) return;
                                        mediaPlayerController.sliderPosition.value = duration.timeStamp;
                                        mediaPlayerController.seekPreview(duration.timeStamp);
                                      },
                                      onSeek: (duration) {
                                        if (!mediaPlayerController.isInitialized.value) return;
                                        mediaPlayerController.isSliderMoving.value = false;
                                        mediaPlayerController.sliderPosition.value = Duration(
                                          seconds: duration.inSeconds.toDouble().floor(),
                                        );
                                        mediaPlayerController.seekTo(
                                          Duration(seconds: duration.inSeconds),
                                          isHorizontalMove: true,
                                        );
                                        mediaPlayerController.play();
                                      },
                                    ),

                                    SizedBox(height: isFullScreen ? 6 : 2),

                                    // 时长
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 当前时长
                                        CommonText.instance(
                                          StringUtils.formatVideoDuration(currentPostion),
                                          isFullScreen ? 12 : 10,
                                          color: CommonColors.white,
                                          fontWeight: CommonFontWeight.medium,
                                        ),
                                        // 总时长
                                        CommonText.instance(
                                          StringUtils.formatVideoDuration(totalDuration),
                                          isFullScreen ? 12 : 10,
                                          color: CommonColors.white,
                                          fontWeight: CommonFontWeight.medium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 横屏、竖屏
                            GestureDetector(
                              onTap: () {
                                mediaPlayerController.triggerFullScreen(
                                  status: !isFullScreen,
                                  onToggleFullScreen: widget.onToggleFullScreen,
                                );
                              },
                              child: Image.asset(
                                isFullScreen ? Assets.commonIconPortrait : Assets.commonIconLandscape,
                                width: isFullScreen ? 28 : 24,
                                height: isFullScreen ? 28 : 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),

        // 长按倍速提示
        _buildDoubleSpeedTips(),

        // 快进快退提示
        _buildFastControlTips(),

        // 时间进度条提示
        _buildTimeProgressTips(),

        /// 音量🔊 控制条展示 音量为0时显示Assets.commonIconVideoNoVolume
        _buildControlTips(_volumePopShow, _volumeValue, Assets.commonIconVideoVolume),

        /// 亮度🌞 控制条展示
        _buildControlTips(_brightnessPopShow, _brightnessValue, Assets.commonIconVideoBrightness),
      ],
    );
  }

  /// 倍速提示
  Widget _buildDoubleSpeedTips() {
    return Obx(() {
      return Align(
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: mediaPlayerController.longPressStatus.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !mediaPlayerController.longPressStatus.value,
            child: Container(
              height: 40,
              margin: EdgeInsets.only(top: isFullscreen ? 24.0 : 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: CommonColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [CommonText.instance('2.0X >>', 14, fontWeight: CommonFontWeight.medium)],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 倍速提示
  Widget _buildFastControlTips() {
    return Obx(() {
      final fastRewindStatus = mediaPlayerController.fastRewindStatus.value;
      final fastForwardStatus = mediaPlayerController.fastForwardStatus.value;
      return Align(
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: fastRewindStatus || fastForwardStatus ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !(fastRewindStatus || fastForwardStatus),
            child: Container(
              height: 40,
              margin: EdgeInsets.only(top: isFullscreen ? 24.0 : 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: CommonColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mediaPlayerController.fastAssets.isNotEmpty)
                    Image.asset(mediaPlayerController.fastAssets, width: 16, height: 16),

                  if (mediaPlayerController.fastAssets.isNotEmpty) SizedBox(width: 8),

                  CommonText.instance(
                    '${mediaPlayerController.fastTips} ${mediaPlayerController.fastSeconds}s',
                    14,
                    fontWeight: CommonFontWeight.medium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// 时间进度条提示
  Widget _buildTimeProgressTips() {
    return Obx(() {
      final isFullScreen = isFullscreen;
      final sliderDuration = mediaPlayerController.sliderPosition.value;
      final totalDur = mediaPlayerController.totalDuration.value;
      final isForward = sliderDuration >= (tempSliderPosition ?? sliderDuration);

      return Align(
        alignment: Alignment.center,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: mediaPlayerController.isSliderMoving.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !mediaPlayerController.isSliderMoving.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mediaPlayerController.previewVideoController != null)
                  Container(
                    width: isFullScreen ? 130 : 90,
                    height: isFullScreen ? 73 : 51,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: CommonColors.color333333, borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Video(
                        controller: mediaPlayerController.previewVideoController!,
                        controls: NoVideoControls,
                        fill: CommonColors.color333333,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: CommonColors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isForward ? Assets.commonIconVideoSlideArrowLeft : Assets.commonIconVideoSlideArrowLeftOn,
                        width: 16,
                        height: 16,
                        color: isForward ? null : CommonColors.primaryColor,
                      ),
                      const SizedBox(width: 8.0),
                      CommonText.instance(
                        StringUtils.formatVideoDuration(sliderDuration),
                        14,
                        fontWeight: CommonFontWeight.medium,
                        color: isForward ? CommonColors.white : CommonColors.primaryColor,
                      ),
                      CommonText.instance(
                        '/${StringUtils.formatVideoDuration(totalDur)}',
                        14,
                        fontWeight: CommonFontWeight.medium,
                        color: isForward ? CommonColors.primaryColor : CommonColors.white,
                      ),
                      const SizedBox(width: 8.0),
                      RotatedBox(
                        quarterTurns: 2,
                        child: Image.asset(
                          isForward ? Assets.commonIconVideoSlideArrowLeftOn : Assets.commonIconVideoSlideArrowLeft,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 控制条展示 (音量/亮度)
  Widget _buildControlTips(RxBool popShow, RxDouble value, String asset) {
    return Obx(() {
      String currentAsset = asset;
      if (asset == Assets.commonIconVideoVolume && value.value == 0) {
        currentAsset = Assets.commonIconVideoNoVolume;
      }

      return Align(
        alignment: isFullscreen ? Alignment.topCenter : Alignment.center,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: popShow.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !popShow.value,
            child: Container(
              height: 40,
              margin: EdgeInsets.only(top: isFullscreen ? 24.0 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CommonColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(currentAsset, width: 24, height: 24),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 150.0,
                    height: 10.0,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Inactive track
                        Container(
                          width: 150.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: CommonColors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        // Active track
                        Container(
                          width: 150.0 * value.value,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: CommonColors.colorDB88E6,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        // Thumb
                        Positioned(
                          left: (150.0 - 10.0) * value.value,
                          child: Container(
                            width: 10.0,
                            height: 10.0,
                            decoration: const BoxDecoration(color: CommonColors.primaryColor, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
