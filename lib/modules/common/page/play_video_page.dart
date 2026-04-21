import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/modules/home/controllers/my_memory_controller.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/bottom_sheet/operation_bottom_sheet_view.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PlayVideoPage extends StatefulWidget {
  const PlayVideoPage({super.key, required this.memoryInfo});

  final MemoryInfo memoryInfo;

  @override
  State<PlayVideoPage> createState() => _PlayVideoPageState();

  static void playVideo({required MemoryInfo memoryInfo}) {
    Get.to(transition: Transition.noTransition, () => PlayVideoPage(memoryInfo: memoryInfo));
  }
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  late MemoryInfo _memoryInfo;
  late VideoPlayerController _videoPlayerController;
  var _isInitialized = false;

  /// 是否显示操作栏
  var _showControls = true;

  /// 当前进度
  var _currentPosition = Duration.zero;

  /// 总时长
  var _totalDuration = Duration.zero;

  /// 隐藏操作栏计时器
  Timer? _hideTimer;

  DateTime? dateTime;

  /// 是否全屏
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    _memoryInfo = widget.memoryInfo;

    dateTime = _memoryInfo.videoTime != null ? DateTime.fromMillisecondsSinceEpoch(_memoryInfo.videoTime!) : null;

    _initPlayer();
  }

  /// 初始化播放器
  void _initPlayer() {
    _videoPlayerController = VideoPlayerController.file(File(_memoryInfo.videoInfo!.path!));

    _videoPlayerController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        // 获取视频总时长
        _totalDuration = _videoPlayerController.value.duration;
        // 自动播放视频
        _videoPlayerController.play();
        // 延迟3s隐藏控制栏
        _startHideTimer();
      });
    });

    _videoPlayerController.addListener(_videoListener);
  }

  /// 视频播放监听
  void _videoListener() {
    if (!_isInitialized || !mounted) return;

    final currentPosition = _videoPlayerController.value.position;
    setState(() {
      // 更新当前播放进度
      _currentPosition = currentPosition;
    });

    if (_videoPlayerController.value.isCompleted) {
      setState(() {
        _showControls = true;
        _currentPosition = _totalDuration;
      });
    }
  }

  /// 切换播放状态
  void _togglePlay() {
    if (!_isInitialized) return;

    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      setState(() {
        _showControls = true;
      });
      _cancelHideTimer();
    } else {
      _videoPlayerController.play();
      _startHideTimer();
    }
  }

  /// 滑动进度条
  void _seekTo(double value) {
    if (!_isInitialized) return;
    int seconds = value.round();
    final newPosition = Duration(seconds: seconds);
    _videoPlayerController.seekTo(newPosition);
    _startHideTimer();
  }

  /// 切换操作栏状态
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _videoPlayerController.value.isPlaying) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  /// 切换全屏
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  /// 开始隐藏控制栏计时
  void _startHideTimer() {
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_videoPlayerController.value.isPlaying && mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _cancelHideTimer();
    super.dispose();
  }

  /// 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _toggleFullScreen();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(child: _buildVideoPlayer()),
        ),
      );
    }

    return PageBase(
      title: 'Play',
      actions: _actionView(),
      child: Stack(
        children: [
          _buildBackground(),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 212.h, color: CommonColors.color333333, child: _buildVideoPlayer()),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Image.asset(Assets.commonFieldTitle, width: 32.w, height: 32.w),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CommonText.instance(
                                _memoryInfo.title ?? '--',
                                16.sp,
                                fontWeight: CommonFontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 日期
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Image.asset(Assets.commonFieldDate, width: 32.w, height: 32.w),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CommonText.instance(
                                dateTime != null
                                    ? "${dateTime!.year}-${dateTime!.month.toString().padLeft(2, '0')}-${dateTime!.day.toString().padLeft(2, '0')}"
                                    : '--',
                                16.sp,
                                color: CommonColors.white.withOpacity(0.5),
                                fontWeight: CommonFontWeight.medium,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 人物
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Image.asset(Assets.commonFieldPerson, width: 32.w, height: 32.w),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CommonText.instance(
                                _memoryInfo.person.isEmptyString() ? '--' : _memoryInfo.person ?? '',
                                16.sp,
                                color: CommonColors.white.withOpacity(0.5),
                                fontWeight: CommonFontWeight.medium,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 描述
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(Assets.commonFieldMemo, width: 32.w, height: 32.w),
                                SizedBox(width: 8.w),
                                if (_memoryInfo.memo.isEmptyString())
                                  CommonText.instance(
                                    '--',
                                    16.sp,
                                    color: CommonColors.white.withOpacity(0.5),
                                    fontWeight: CommonFontWeight.medium,
                                  ),
                              ],
                            ),

                            if (_memoryInfo.memo.isNotEmptyString()) ...[
                              SizedBox(height: 8.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                decoration: BoxDecoration(
                                  color: CommonColors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: CommonText.instance(
                                  _memoryInfo.memo!,
                                  16.sp,
                                  color: CommonColors.white.withOpacity(0.5),
                                  fontWeight: CommonFontWeight.medium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        if (_memoryInfo.videoInfo!.thumbnailPath != null && _memoryInfo.videoInfo!.thumbnailPath!.isNotEmpty)
          Positioned.fill(
            child: Image.file(
              File(_memoryInfo.videoInfo!.thumbnailPath!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: CommonColors.black.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 视频播放器（或封面）
        Center(
          child: _isInitialized
              ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_memoryInfo.videoInfo!.thumbnailPath != null &&
                        _memoryInfo.videoInfo!.thumbnailPath!.isNotEmpty)
                      Image.file(
                        File(_memoryInfo.videoInfo!.thumbnailPath!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    const CircularProgressIndicator(color: CommonColors.primaryColor),
                  ],
                ),
        ),

        // 背景轻触切换控件
        GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Container(color: Colors.transparent),
        ),

        // 操作栏
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !_showControls,
            child: SafeArea(
              child: Stack(
                children: [
                  // 顶部操作栏（全屏时显示返回按钮）
                  if (_isFullScreen)
                    Positioned(
                      top: 20,
                      left: 32,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleFullScreen,
                            child: Image.asset(Assets.commonNavBack, width: 32, height: 32),
                          ),
                          SizedBox(width: 14),
                          CommonText.instance(_memoryInfo.title ?? '', 16, fontWeight: CommonFontWeight.bold),
                        ],
                      ),
                    ),

                  // 播放/暂停按钮
                  Center(
                    child: _showControls
                        ? GestureDetector(
                            onTap: _togglePlay,
                            child: Image.asset(
                              _videoPlayerController.value.isPlaying
                                  ? Assets.commonVideoPause
                                  : Assets.commonVideoPlayBig,
                              width: 48,
                              height: 48,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // 底部操作栏
                  Positioned(
                    bottom: _isFullScreen ? 16 : 8,
                    left: _isFullScreen ? 32 : 16,
                    right: _isFullScreen ? 32 : 16,
                    child: Row(
                      children: [
                        // 播放/暂停按钮
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Image.asset(
                            _videoPlayerController.value.isPlaying ? Assets.commonIconPause : Assets.commonIconPlay,
                            width: 24,
                            height: 24,
                          ),
                        ),

                        SizedBox(width: 10),

                        // 时长、进度条
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 进度条
                              Row(
                                children: [
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final duration = _totalDuration.inSeconds.toDouble();
                                        final position = _currentPosition.inSeconds.toDouble();
                                        final value = position.clamp(0.0, duration > 0 ? duration : 0.0);

                                        return SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            //轨道的粗细
                                            trackHeight: 4,
                                            //滑块形状 半径
                                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                                            thumbColor: CommonColors.primaryColor,
                                            //滑块已滑动部分的轨道颜色
                                            activeTrackColor: CommonColors.colorDB88E6,
                                            //滑块未滑动部分的轨道颜色
                                            inactiveTrackColor: CommonColors.white.withOpacity(0.3),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Slider(
                                            value: value,
                                            min: 0.0,
                                            max: duration > 0 ? duration : 1.0,
                                            onChanged: (v) {
                                              _seekTo(v);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 2),

                              // 时长
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 当前时长
                                  CommonText.instance(
                                    _formatDuration(_currentPosition),
                                    10,
                                    color: CommonColors.white,
                                    fontWeight: CommonFontWeight.medium,
                                  ),
                                  // 总时长
                                  CommonText.instance(
                                    _formatDuration(_totalDuration),
                                    10,
                                    color: CommonColors.white,
                                    fontWeight: CommonFontWeight.medium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 10),

                        // 横屏、竖屏
                        GestureDetector(
                          onTap: _toggleFullScreen,
                          child: Image.asset(
                            _isFullScreen ? Assets.commonIconPortrait : Assets.commonIconLandscape,
                            width: 24,
                            height: 24,
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
      ],
    );
  }

  _actionView() {
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      onPressed: () {
        OperationBottomSheetView.show(
          editAction: () async {
            if (_isInitialized && _videoPlayerController.value.isPlaying) {
              _videoPlayerController.pause();
              setState(() {
                _showControls = true;
              });
              _cancelHideTimer();
            }

            final result = await Get.toNamed(Routes.editVideo, arguments: {'memoryInfo': _memoryInfo});
            if (result != null && result is MemoryInfo) {
              final oldPath = _memoryInfo.videoInfo?.path;
              setState(() {
                _memoryInfo = result;
                dateTime = _memoryInfo.videoTime != null
                    ? DateTime.fromMillisecondsSinceEpoch(_memoryInfo.videoTime!)
                    : null;

                if (oldPath != _memoryInfo.videoInfo?.path) {
                  _videoPlayerController.removeListener(_videoListener);
                  _videoPlayerController.dispose();
                  _isInitialized = false;
                  _initPlayer();
                }
              });
            }
          },
          deleteAction: () async {
            await Storage.deleteSavedMemory(_memoryInfo.id ?? '');
            Get.find<MyMemoryController>().getDataFromLocal();
            Get.back();
          },
        );
      },
      child: Image.asset(Assets.commonOperationMore, width: 24.w, height: 24.w),
    );
  }
}
