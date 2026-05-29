import 'dart:async';

import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/common_ui.dart';
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
            // 锁定时🔒禁用
            if (mediaPlayerController.controlsLock.value) {
              return;
            }

            // 双击切换播放状态
            mediaPlayerController.togglePlay();
          },
          onLongPress: () {
            // 锁定时🔒禁用
            if (mediaPlayerController.controlsLock.value) {
              return;
            }

            mediaPlayerController.longPressStatus.value = true;
            tempSpeed = mediaPlayerController.defaultSpeed;
            //长按2倍速度
            mediaPlayerController.setPlaybackSpeed(tempSpeed * 2);
          },
          onLongPressEnd: (details) {
            // 锁定时🔒禁用
            if (mediaPlayerController.controlsLock.value) {
              return;
            }

            mediaPlayerController.longPressStatus.value = false;
            //长按结束时恢复本来的速度
            mediaPlayerController.setPlaybackSpeed(tempSpeed);
          },
          onHorizontalDragUpdate: (details) {
            // 锁定时🔒禁用
            if (mediaPlayerController.controlsLock.value) {
              return;
            }

            final int curSliderPosition = mediaPlayerController.sliderPosition.value.inMilliseconds;
            final double scale = 90000 / MediaQuery.sizeOf(context).width;
            final Duration pos = Duration(milliseconds: curSliderPosition + (details.delta.dx * scale).round());
            final Duration result = pos.clamp(Duration.zero, mediaPlayerController.totalDuration.value);
            mediaPlayerController.isSliderMoving.value = true;
            mediaPlayerController.sliderPosition.value = result;
          },
          onHorizontalDragEnd: (details) {
            // 锁定时🔒禁用
            if (mediaPlayerController.controlsLock.value) {
              return;
            }

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

        Obx(() {
          if (mediaPlayerController.mediaDataStatus.loading || mediaPlayerController.isBuffering.value) {
            return Center(child: loadingIndicator(size: 30.w, strokeWidth: 2));
          } else {
            return const SizedBox();
          }
        }),

        // 长按倍速提示
        _buildDoubleSpeedTips(),

        /// 音量🔊 控制条展示
        _buildVolumnTips(),

        /// 亮度🌞 控制条展示
        _buildBrightnessTips(),

        //面板层
        // Visibility(
        //   visible: mediaPlayerController._controlPanelShow,
        //   child: SafeArea(
        //     top: false,
        //     bottom: false,
        //     child: Column(
        //       children: [
        //         //上面板(返回,菜单...)
        //         Container(
        //           decoration: panelDecoration,
        //           child: Row(
        //             children: [
        //               //返回按钮
        //               const BackButton(color: Colors.white),
        //               //主页面按钮
        //               IconButton(
        //                 onPressed: () {
        //                   //回到主页面
        //                   Navigator.popUntil(context, (route) => route.isFirst);
        //                 },
        //                 icon: const Icon(Icons.home_outlined, color: Colors.white),
        //               ),
        //               const Spacer(),
        //               // PopupMenuButton(
        //               //   icon: const Icon(Icons.more_vert_rounded, color: iconColor),
        //               //   itemBuilder: (context) {
        //               //     return <PopupMenuEntry<String>>[
        //               //       PopupMenuItem(
        //               //         padding: EdgeInsets.zero,
        //               //         value: "弹幕",
        //               //         child: Row(
        //               //           children: [
        //               //             const Padding(
        //               //               padding: EdgeInsets.all(12),
        //               //               child: Icon(Icons.format_list_bulleted, size: 24),
        //               //             ),
        //               //             const Text("弹幕"),
        //               //             const Spacer(),
        //               //             StatefulBuilder(
        //               //               key: danmakuCheckBoxKey,
        //               //               builder: (context, setState) {
        //               //                 return Checkbox(
        //               //                   value:
        //               //                       widget
        //               //                           .controller
        //               //                           .biliVideoPlayerController
        //               //                           .biliDanmakuController
        //               //                           ?.isDanmakuOpened ??
        //               //                       false,
        //               //                   onChanged: (value) {
        //               //                     if (value != null) {
        //               //                       toggleDanmaku();
        //               //                     }
        //               //                   },
        //               //                 );
        //               //               },
        //               //             ),
        //               //           ],
        //               //         ),
        //               //       ),
        //               //       const PopupMenuItem(
        //               //         padding: EdgeInsets.zero,
        //               //         value: "播放速度",
        //               //         child: Row(
        //               //           children: [
        //               //             Padding(padding: EdgeInsets.all(12), child: Icon(Icons.speed_rounded, size: 24)),
        //               //             Text("播放速度"),
        //               //           ],
        //               //         ),
        //               //       ),
        //               //       PopupMenuItem(
        //               //         value: "画质",
        //               //         child: Text(
        //               //           "画质: ${mediaPlayerController._biliVideoPlayerController.videoPlayItem!.quality.description ?? "未知"}",
        //               //         ),
        //               //       ),
        //               //       PopupMenuItem(
        //               //         value: "音质",
        //               //         child: Text(
        //               //           "音质: ${mediaPlayerController._biliVideoPlayerController.audioPlayItem!.quality.description ?? "未知"}",
        //               //         ),
        //               //       ),
        //               //       const PopupMenuItem(value: "弹幕字体大小", child: Text("弹幕字体大小")),
        //               //       const PopupMenuItem(value: "弹幕不透明度", child: Text("弹幕不透明度")),
        //               //       const PopupMenuItem(value: "弹幕速度", child: Text("弹幕速度")),
        //               //     ];
        //               //   },
        //               //   onSelected: (value) {
        //               //     switch (value) {
        //               //       case "弹幕":
        //               //         toggleDanmaku();
        //               //         break;
        //               //       case "播放速度":
        //               //         showDialog(
        //               //           context: context,
        //               //           builder: (context) => SliderDialog(
        //               //             title: "播放速度",
        //               //             initValue: mediaPlayerController._biliVideoPlayerController.speed,
        //               //             min: 0.25,
        //               //             max: 4.00,
        //               //             divisions: 15,
        //               //             onOk: (value) {
        //               //               mediaPlayerController._biliVideoPlayerController.setPlayBackSpeed(value);
        //               //             },
        //               //             buildLabel: (selectingValue) => "${selectingValue}X",
        //               //           ),
        //               //         );
        //               //
        //               //         break;
        //               //       case "画质":
        //               //         showDialog(
        //               //           context: context,
        //               //           builder: (context) {
        //               //             return AlertDialog(
        //               //               scrollable: true,
        //               //               title: const Text("选择画质"),
        //               //               actions: [
        //               //                 TextButton(
        //               //                   onPressed: () {
        //               //                     Navigator.of(context).pop();
        //               //                   },
        //               //                   child: Text("取消", style: TextStyle(color: Theme.of(context).hintColor)),
        //               //                 ),
        //               //               ],
        //               //               content: Column(children: buildVideoQualityTiles()),
        //               //             );
        //               //           },
        //               //         );
        //               //         break;
        //               //       case "音质":
        //               //         showDialog(
        //               //           context: context,
        //               //           builder: (context) {
        //               //             return AlertDialog(
        //               //               scrollable: true,
        //               //               title: const Text("选择音质"),
        //               //               actions: [
        //               //                 TextButton(
        //               //                   onPressed: () {
        //               //                     Navigator.of(context).pop();
        //               //                   },
        //               //                   child: Text("取消", style: TextStyle(color: Theme.of(context).hintColor)),
        //               //                 ),
        //               //               ],
        //               //               content: Column(children: buildAudioQualityTiles()),
        //               //             );
        //               //           },
        //               //         );
        //               //         break;
        //               //       case '弹幕字体大小':
        //               //         showDialog(
        //               //           context: context,
        //               //           builder: (context) => SliderDialog(
        //               //             title: '弹幕字体大小',
        //               //             initValue:
        //               //                 mediaPlayerController._biliVideoPlayerController.biliDanmakuController!.fontScale,
        //               //             showCancelButton: false,
        //               //             min: 0.25,
        //               //             max: 4,
        //               //             divisions: 100,
        //               //             buildLabel: (selectingValue) => "${selectingValue.toStringAsFixed(2)}X",
        //               //             onChanged: (selectingValue) {
        //               //               mediaPlayerController._biliVideoPlayerController.biliDanmakuController!.fontScale =
        //               //                   selectingValue;
        //               //               if (SettingsUtil.getValue(
        //               //                 SettingsStorageKeys.rememberDanmakuSettings,
        //               //                 defaultValue: true,
        //               //               )) {
        //               //                 SettingsUtil.setValue(SettingsStorageKeys.defaultDanmakuScale, selectingValue);
        //               //               }
        //               //             },
        //               //           ),
        //               //         );
        //               //         break;
        //               //       case '弹幕不透明度':
        //               //         showDialog(
        //               //           context: context,
        //               //           builder: (context) => SliderDialog(
        //               //             title: '弹幕不透明度',
        //               //             initValue:
        //               //                 mediaPlayerController._biliVideoPlayerController.biliDanmakuController!.fontOpacity,
        //               //             showCancelButton: false,
        //               //             min: 0.01,
        //               //             max: 1.0,
        //               //             divisions: 100,
        //               //             buildLabel: (selectingValue) => "${(selectingValue * 100).toStringAsFixed(0)}%",
        //               //             onChanged: (selectingValue) {
        //               //               mediaPlayerController._biliVideoPlayerController.biliDanmakuController!.fontOpacity =
        //               //                   selectingValue;
        //               //               if (SettingsUtil.getValue(
        //               //                 SettingsStorageKeys.rememberDanmakuSettings,
        //               //                 defaultValue: true,
        //               //               )) {
        //               //                 SettingsUtil.setValue(SettingsStorageKeys.defaultDanmakuOpacity, selectingValue);
        //               //               }
        //               //             },
        //               //           ),
        //               //         );
        //               //         break;
        //               //       case '弹幕速度':
        //               //         showDialog(
        //               //           context: context,
        //               //           builder: (context) => SliderDialog(
        //               //             title: '弹幕速度',
        //               //             initValue: mediaPlayerController._biliVideoPlayerController.biliDanmakuController!.speed,
        //               //             showCancelButton: false,
        //               //             min: 0.25,
        //               //             max: 4,
        //               //             divisions: 15,
        //               //             buildLabel: (selectingValue) => "${selectingValue}X",
        //               //             onChanged: (selectingValue) {
        //               //               mediaPlayerController._biliVideoPlayerController.biliDanmakuController!.speed =
        //               //                   selectingValue;
        //               //               if (SettingsUtil.getValue(
        //               //                 SettingsStorageKeys.rememberDanmakuSettings,
        //               //                 defaultValue: true,
        //               //               )) {
        //               //                 SettingsUtil.setValue(SettingsStorageKeys.defaultDanmakuSpeed, selectingValue);
        //               //               }
        //               //             },
        //               //           ),
        //               //         );
        //               //         break;
        //               //       default:
        //               //         log(value);
        //               //     }
        //               //   },
        //               // ),
        //             ],
        //           ),
        //         ),
        //         //中间留空
        //         const Spacer(),
        //         //下面板(播放按钮,进度条...)
        //         Container(
        //           decoration: panelDecoration,
        //           child: Row(
        //             children: [
        //               StatefulBuilder(
        //                 key: playButtonKey,
        //                 builder: (context, setState) {
        //                   late final IconData iconData;
        //                   if (mediaPlayerController._isPlayerEnd) {
        //                     iconData = Icons.refresh_rounded;
        //                   } else if (mediaPlayerController._isPlayerPlaying) {
        //                     iconData = Icons.pause_rounded;
        //                   } else {
        //                     iconData = Icons.play_arrow_rounded;
        //                   }
        //                   return //播放按钮
        //                   IconButton(
        //                     color: iconColor,
        //                     onPressed: () async {
        //                       if (mediaPlayerController.mediaPlayerController.isPlaying) {
        //                         await mediaPlayerController.mediaPlayerController.pause();
        //                       } else {
        //                         if (mediaPlayerController.mediaPlayerController.hasError) {
        //                           //如果是出错状态, 重新加载
        //                           await mediaPlayerController.mediaPlayerController.reloadWidget();
        //                         } else {
        //                           //不是出错状态, 就继续播放
        //                           await mediaPlayerController.mediaPlayerController.play();
        //                         }
        //                       }
        //                       mediaPlayerController._isPlayerPlaying = !mediaPlayerController._isPlayerPlaying;
        //                       setState(() {});
        //                     },
        //                     icon: Icon(iconData),
        //                   );
        //                 },
        //               ),
        //               //进度条
        //               Expanded(
        //                 child: StatefulBuilder(
        //                   key: sliderKey,
        //                   builder: (context, setState) {
        //                     return Slider(
        //                       min: 0,
        //                       max: mediaPlayerController.mediaPlayerController.totalDuration.inMilliseconds.toDouble(),
        //                       value: clampDouble(
        //                         mediaPlayerController._currentPosition.inMilliseconds.toDouble(),
        //                         0,
        //                         mediaPlayerController.mediaPlayerController.totalDuration.inMilliseconds.toDouble(),
        //                       ),
        //                       secondaryTrackValue: clampDouble(
        //                         mediaPlayerController._fartherestBuffed.inMilliseconds.toDouble(),
        //                         0,
        //                         mediaPlayerController.mediaPlayerController.totalDuration.inMilliseconds.toDouble(),
        //                       ),
        //                       onChanged: (value) {
        //                         if (mediaPlayerController._isSliderDraging) {
        //                           mediaPlayerController._currentPosition = Duration(milliseconds: value.toInt());
        //                         }
        //                       },
        //                       onChangeStart: (value) {
        //                         mediaPlayerController._isSliderDraging = true;
        //                       },
        //                       onChangeEnd: (value) {
        //                         if (mediaPlayerController._isSliderDraging) {
        //                           mediaPlayerController.mediaPlayerController.seekTo(
        //                             Duration(milliseconds: value.toInt()),
        //                           );
        //                           mediaPlayerController._isSliderDraging = false;
        //                         }
        //                       },
        //                     );
        //                   },
        //                 ),
        //               ),
        //               //时长
        //               StatefulBuilder(
        //                 key: durationTextKey,
        //                 builder: (context, setState) {
        //                   return Text(
        //                     "${StringFormatUtils.timeLengthFormat(mediaPlayerController._currentPosition.inSeconds)}/${StringFormatUtils.timeLengthFormat(mediaPlayerController.mediaPlayerController.totalDuration.inSeconds)}",
        //                     style: const TextStyle(color: textColor),
        //                   );
        //                 },
        //               ),
        //               // 全屏按钮
        //               IconButton(
        //                 onPressed: () {
        //                   // log("full:${mediaPlayerController.isFullScreen}");
        //                   toggleFullScreen();
        //                 },
        //                 icon: const Icon(Icons.fullscreen_rounded, color: iconColor),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  /// 倍速提示
  Widget _buildDoubleSpeedTips() {
    return Obx(
      () => Align(
        alignment: Alignment.topCenter,
        child: FractionalTranslation(
          translation: const Offset(0.0, 0.3), // 上下偏移量（负数向上偏移）
          child: AnimatedOpacity(
            curve: Curves.easeInOut,
            opacity: mediaPlayerController.longPressStatus.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0x88000000), borderRadius: BorderRadius.circular(16.0)),
              height: 32.0,
              width: 70.0,
              child: const Center(
                child: Text('倍速中', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 音量提示
  Widget _buildVolumnTips() {
    return Obx(() {
      return Align(
        alignment: Alignment.center,
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: _volumePopShow.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              decoration: BoxDecoration(color: const Color(0x88000000), borderRadius: BorderRadius.circular(64.0)),
              height: 34.0,
              child: Row(
                children: <Widget>[
                  Icon(Icons.volume_mute, size: 18.0),
                  const SizedBox(width: 4.0),
                  Container(
                    constraints: const BoxConstraints(minWidth: 30.0),
                    child: Text(
                      '${(_volumeValue.value * 100.0).round()}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.0, color: Colors.white),
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

  /// 亮度提示
  Widget _buildBrightnessTips() {
    return Obx(() {
      return Align(
        child: AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: _brightnessPopShow.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              decoration: BoxDecoration(color: const Color(0x88000000), borderRadius: BorderRadius.circular(64.0)),
              height: 34.0,
              child: Row(
                children: <Widget>[
                  Icon(Icons.brightness_1_sharp, size: 18.0),
                  const SizedBox(width: 4.0),
                  Container(
                    constraints: const BoxConstraints(minWidth: 30.0),
                    child: Text(
                      '${(_brightnessValue.value * 100.0).round()}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.0, color: Colors.white),
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
