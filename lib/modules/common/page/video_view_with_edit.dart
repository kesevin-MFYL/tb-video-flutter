import 'dart:io';
import 'package:editvideo/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoViewWithEdit extends StatefulWidget {
  final String videoUrl;
  final String? thumbPath;

  const VideoViewWithEdit({super.key, required this.videoUrl, this.thumbPath});

  @override
  State<VideoViewWithEdit> createState() => VideoViewWithEditState();
}

class VideoViewWithEditState extends State<VideoViewWithEdit> {
  late VideoPlayerController _videoPlayerController;
  var _isInitialized = false;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant VideoViewWithEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _videoPlayerController.dispose();
      _isInitialized = false;
      _initPlayer();
    }
  }

  /// 初始化播放器
  void _initPlayer() {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoUrl));

    _videoPlayerController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    });

    _videoPlayerController.addListener(_videoListener);
  }

  /// 视频播放监听
  void _videoListener() {
    if (!_isInitialized || !mounted) return;

    final isPlaying = _videoPlayerController.value.isPlaying;

    if (_isPlaying != isPlaying) {
      _isPlaying = isPlaying;
      if (_isPlaying) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }

    if (_videoPlayerController.value.isCompleted) {
      setState(() {});
    }
  }

  /// 切换播放状态
  void _togglePlay() {
    if (!_isInitialized) return;

    if (_videoPlayerController.value.isPlaying) {
      setState(() {
        _videoPlayerController.pause();
      });
    } else {
      setState(() {
        _videoPlayerController.play();
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _videoPlayerController.removeListener(_videoListener);
    _videoPlayerController.dispose();
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
                      )
                    else
                      Center(
                        child: Image.asset(Assets.commonIconVideoError, width: 80.w, height: 80.w, fit: BoxFit.cover),
                      ),
                  ],
                ),
        ),

        Center(
          child: GestureDetector(
            onTap: _togglePlay,
            child: Image.asset(
              _videoPlayerController.value.isPlaying ? Assets.commonVideoPause : Assets.commonVideoPlayBig,
              width: 48.w,
              height: 48.w,
            ),
          ),
        ),
      ],
    );
  }
}
