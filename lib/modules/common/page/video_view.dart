import 'dart:async';
import 'dart:io';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String videoUrl;
  final String? thumbPath;
  final String? title;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const VideoView({
    super.key,
    required this.videoUrl,
    this.thumbPath,
    this.title,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  State<VideoView> createState() => VideoViewState();
}

class VideoViewState extends State<VideoView> {
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

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _videoPlayerController.removeListener(_videoListener);
      _videoPlayerController.dispose();
      _isInitialized = false;
      _initPlayer();
    }

    // if (oldWidget.isFullScreen != widget.isFullScreen) {
    //   if (widget.isFullScreen) {
    //     if (_isInitialized && _videoPlayerController.value.isPlaying) {
    //       _startHideTimer();
    //     }
    //   } else {
    //     _cancelHideTimer();
    //     setState(() {
    //       _showControls = true;
    //     });
    //   }
    // }
  }

  /// 初始化播放器
  void _initPlayer() {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoUrl));

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

  void pauseVideo() {
    if (_isInitialized && _videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      setState(() {
        _showControls = true;
      });
      _cancelHideTimer();
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
    // if (!widget.isFullScreen) return;
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls && _videoPlayerController.value.isPlaying) {
      _startHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  /// 开始隐藏控制栏计时
  void _startHideTimer() {
    _cancelHideTimer();
    // if (!widget.isFullScreen) return;

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
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
    _cancelHideTimer();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
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
                    if (widget.thumbPath != null && widget.thumbPath!.isNotEmpty)
                      Image.file(
                        File(widget.thumbPath!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, object, stack) {
                          return Center(
                            child: Image.asset(Assets.commonIconVideoError, width: 160, height: 160, fit: BoxFit.cover),
                          );
                        },
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
            child: Stack(
              children: [
                // 顶部操作栏（全屏时显示返回按钮）
                if (widget.isFullScreen)
                  Positioned(
                    top: 20,
                    left: 32,
                    right: 32,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onToggleFullScreen,
                          child: Image.asset(Assets.commonNavBack, width: 32, height: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CommonText.instance(
                            widget.title ?? '',
                            16,
                            fontWeight: CommonFontWeight.bold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                  bottom: widget.isFullScreen ? 16 : 8,
                  left: widget.isFullScreen ? 32 : 16,
                  right: widget.isFullScreen ? 32 : 16,
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

                      const SizedBox(width: 10),

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
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
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
                                          onChanged: _seekTo,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

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

                      const SizedBox(width: 10),

                      // 横屏、竖屏
                      GestureDetector(
                        onTap: widget.onToggleFullScreen,
                        child: Image.asset(
                          widget.isFullScreen ? Assets.commonIconPortrait : Assets.commonIconLandscape,
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
      ],
    );
  }
}
