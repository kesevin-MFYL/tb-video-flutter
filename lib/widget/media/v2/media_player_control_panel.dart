import 'dart:async';

import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/media/utils/string_utils.dart';
import 'package:editvideo/widget/media/v2/media_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// 播放器控制面板
class MediaPlayerControlPanel extends StatefulWidget {
  const MediaPlayerControlPanel(this.controller, {super.key});

  final MediaPlayerController controller;

  @override
  State<MediaPlayerControlPanel> createState() => _MediaPlayerControlPanelState();
}

class _MediaPlayerControlPanelState extends State<MediaPlayerControlPanel> {
  late MediaPlayerController mediaPlayerController;

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

  late double tempSpeed;
  Duration? tempSliderPosition;

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
        _volumeValue.value = (await FlutterVolumeController.getVolume())!;
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
        //手势识别层
        GestureDetector(
          onTap: () {
            // 切换操作栏状态
            mediaPlayerController.toggleControls();
          },
          onDoubleTap: () {
            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            // 双击切换播放状态
            mediaPlayerController.togglePlay();
          },
          onLongPress: () {
            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            mediaPlayerController.longPressStatus.value = true;
            tempSpeed = mediaPlayerController.defaultSpeed;
            //长按2倍速度
            mediaPlayerController.setPlaybackSpeed(tempSpeed * 2);
          },
          onLongPressEnd: (details) {
            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            mediaPlayerController.longPressStatus.value = false;
            //长按结束时恢复本来的速度
            mediaPlayerController.setPlaybackSpeed(tempSpeed);
          },
          onHorizontalDragStart: (details) {
            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            tempSliderPosition = mediaPlayerController.currentPosition.value;
          },
          onHorizontalDragUpdate: (details) {
            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            final int curSliderPosition = mediaPlayerController.sliderPosition.value.inMilliseconds;
            final double scale = 90000 / MediaQuery.sizeOf(context).width;
            final Duration pos = Duration(milliseconds: curSliderPosition + (details.delta.dx * scale).round());
            final Duration result = pos.clamp(Duration.zero, mediaPlayerController.totalDuration.value);
            mediaPlayerController.sliderPosition.value = result;
            mediaPlayerController.isSliderMoving.value = true;
          },
          onHorizontalDragEnd: (details) {
            // 缓存中或锁定时🔒禁用
            if (mediaPlayerController.isBuffering.value || mediaPlayerController.controlsLock.value) return;

            mediaPlayerController.isSliderMoving.value = false;
            mediaPlayerController.seekTo(mediaPlayerController.sliderPosition.value, isHorizontalMove: true);
          },
          onVerticalDragUpdate: (DragUpdateDetails details) async {
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
              final double level =
                  (mediaPlayerController.isFullScreen.value ? Get.size.height : screenWidth * 9 / 16) * 3;
              final double brightness = _brightnessValue.value - delta / level;
              final double result = brightness.clamp(0.0, 1.0);
              setBrightness(result);
            } else {
              // 右边区域 👈
              // EasyThrottle.throttle(
              //     'setVolume', const Duration(milliseconds: 20), () {
              //
              // });
              final double level = (mediaPlayerController.isFullScreen.value ? Get.size.height : screenWidth * 9 / 16);
              final double volume = _volumeValue.value - double.parse(delta.toStringAsFixed(1)) / level;
              final double result = volume.clamp(0.0, 1.0);
              setVolume(result);
            }
          },
          onVerticalDragEnd: (DragEndDetails details) {},
        ),

        Obx(() {
          final showControls = mediaPlayerController.showControls.value;
          return AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !showControls,
              child: Stack(
                children: [
                  // // 顶部操作栏（全屏时显示返回按钮）
                  // if (widget.isFullScreen)
                  //   Positioned(
                  //     top: 20,
                  //     left: 56,
                  //     right: 56,
                  //     child: Row(
                  //       children: [
                  //         GestureDetector(
                  //           onTap: widget.onToggleFullScreen,
                  //           child: Image.asset(Assets.commonNavBack, width: 32, height: 32),
                  //         ),
                  //         const SizedBox(width: 14),
                  //         Expanded(
                  //           child: CommonText.instance(
                  //             widget.title ?? '',
                  //             16,
                  //             fontWeight: CommonFontWeight.bold,
                  //             maxLines: 1,
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),

                  // 播放/暂停按钮
                  Center(
                    child: showControls
                        ? GestureDetector(
                            onTap: () {},
                            child: Image.asset(Assets.commonVideoPlayBig, width: 48, height: 48, fit: BoxFit.cover),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // 底部操作栏
                  // Positioned(
                  //   bottom: widget.isFullScreen ? 32 : 8,
                  //   left: widget.isFullScreen ? 56 : 16,
                  //   right: widget.isFullScreen ? 56 : 16,
                  //   child: Row(
                  //     children: [
                  //       // 播放/暂停按钮
                  //       GestureDetector(
                  //         onTap: _togglePlay,
                  //         child: Image.asset(
                  //           _videoPlayerController.value.isPlaying ? Assets.commonIconPause : Assets.commonIconPlay,
                  //           width: widget.isFullScreen ? 32 : 24,
                  //           height: widget.isFullScreen ? 32 : 24,
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  //
                  //       SizedBox(width: widget.isFullScreen ? 16 : 10),
                  //
                  //       // 时长、进度条
                  //       Expanded(
                  //         child: Column(
                  //           mainAxisSize: MainAxisSize.min,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             // 进度条
                  //             Row(
                  //               children: [
                  //                 Expanded(
                  //                   child: Builder(
                  //                     builder: (context) {
                  //                       final duration = _totalDuration.inSeconds.toDouble();
                  //                       final position = _currentPosition.inSeconds.toDouble();
                  //                       final value = position.clamp(0.0, duration > 0 ? duration : 0.0);
                  //
                  //                       return SliderTheme(
                  //                         data: SliderTheme.of(context).copyWith(
                  //                           //轨道的粗细
                  //                           trackHeight: 4,
                  //                           //滑块形状 半径
                  //                           thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  //                           thumbColor: CommonColors.primaryColor,
                  //                           //滑块已滑动部分的轨道颜色
                  //                           activeTrackColor: CommonColors.colorDB88E6,
                  //                           //滑块未滑动部分的轨道颜色
                  //                           inactiveTrackColor: CommonColors.white.withOpacity(0.3),
                  //                           padding: EdgeInsets.zero,
                  //                         ),
                  //                         child: Slider(
                  //                           value: value,
                  //                           min: 0.0,
                  //                           max: duration > 0 ? duration : 1.0,
                  //                           onChanged: _seekTo,
                  //                         ),
                  //                       );
                  //                     },
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //
                  //             SizedBox(height: widget.isFullScreen ? 4 : 2),
                  //
                  //             // 时长
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 // 当前时长
                  //                 CommonText.instance(
                  //                   _formatDuration(_currentPosition),
                  //                   widget.isFullScreen ? 12 : 10,
                  //                   color: CommonColors.white,
                  //                   fontWeight: CommonFontWeight.medium,
                  //                 ),
                  //                 // 总时长
                  //                 CommonText.instance(
                  //                   _formatDuration(_totalDuration),
                  //                   widget.isFullScreen ? 12 : 10,
                  //                   color: CommonColors.white,
                  //                   fontWeight: CommonFontWeight.medium,
                  //                 ),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //
                  //       SizedBox(width: widget.isFullScreen ? 16 : 10),
                  //
                  //       // 横屏、竖屏
                  //       GestureDetector(
                  //         onTap: widget.onToggleFullScreen,
                  //         child: Image.asset(
                  //           widget.isFullScreen ? Assets.commonIconPortrait : Assets.commonIconLandscape,
                  //           width: widget.isFullScreen ? 28 : 24,
                  //           height: widget.isFullScreen ? 28 : 24,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        }),

        /// 数据加载错误或缓存中
        Obx(() {
          if (mediaPlayerController.mediaDataStatus.loading || mediaPlayerController.isBuffering.value) {
            return Center(child: loadingIndicator(size: 30, strokeWidth: 2));
          } else {
            return const SizedBox();
          }
        }),

        // 长按倍速提示
        _buildDoubleSpeedTips(),

        // 时间进度条提示
        _buildTimeProgressTips(),

        /// 音量🔊 控制条展示
        _buildControlTips(_volumePopShow, _volumeValue, Assets.commonIconVideoVolume),

        /// 亮度🌞 控制条展示
        _buildControlTips(_brightnessPopShow, _brightnessValue, Assets.commonIconVideoBrightness),
      ],
    );
  }

  /// 倍速提示
  Widget _buildDoubleSpeedTips() {
    return Obx(
      () => Align(
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: mediaPlayerController.longPressStatus.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !mediaPlayerController.longPressStatus.value,
            child: Container(
              height: 40,
              margin: EdgeInsets.only(top: mediaPlayerController.isFullScreen.value ? 24.0 : 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: CommonColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [CommonText.instance('2.0X >>', 14.sp, fontWeight: CommonFontWeight.medium)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 时间进度条提示
  Widget _buildTimeProgressTips() {
    return Obx(() {
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
            child: Container(
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
                    Assets.commonIconVideoSlideArrowLeft,
                    width: 16,
                    height: 16,
                    color: isForward ? null : CommonColors.primaryColor,
                  ),
                  const SizedBox(width: 8.0),
                  CommonText.instance(
                    StringUtils.formatVideoDuration(sliderDuration),
                    14.sp,
                    fontWeight: CommonFontWeight.medium,
                    color: isForward ? CommonColors.white : CommonColors.primaryColor,
                  ),
                  CommonText.instance(
                    '/${StringUtils.formatVideoDuration(totalDur)}',
                    14.sp,
                    fontWeight: CommonFontWeight.medium,
                    color: isForward ? CommonColors.primaryColor : CommonColors.white,
                  ),
                  const SizedBox(width: 8.0),
                  RotatedBox(
                    quarterTurns: 2,
                    child: Image.asset(
                      Assets.commonIconVideoSlideArrowLeft,
                      width: 16,
                      height: 16,
                      color: isForward ? CommonColors.primaryColor : null,
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

  /// 控制条展示 (音量/亮度)
  Widget _buildControlTips(RxBool popShow, RxDouble value, String asset) {
    return Obx(() {
      return Align(
        alignment: Alignment.center,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: popShow.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(
            ignoring: !popShow.value,
            child: Container(
              height: 40,
              margin: EdgeInsets.only(top: mediaPlayerController.isFullScreen.value ? 24.0 : 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CommonColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(asset, width: 24, height: 24),
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
