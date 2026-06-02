import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/widget/media/media_player_control_panel.dart';
import 'package:editvideo/widget/media/media_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaPlayerView extends StatefulWidget {
  const MediaPlayerView({
    super.key,
    required this.mediaId,
    required this.mediaPlayerController,
    required this.mediaPlayerFuture,
    this.onChooseEpisode,
    this.onReload,
  });

  final int mediaId;
  final MediaPlayerController mediaPlayerController;
  final Future<bool>? mediaPlayerFuture;
  final VoidCallback? onReload;
  final VoidCallback? onChooseEpisode;

  @override
  State<MediaPlayerView> createState() => _MediaPlayerViewState();
}

class _MediaPlayerViewState extends State<MediaPlayerView> {
  Future<bool>? _currentFuture;

  @override
  void initState() {
    super.initState();
    _currentFuture = widget.mediaPlayerFuture;
  }

  @override
  void didUpdateWidget(covariant MediaPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果父组件传入了新的 future，则更新本地的 future
    if (oldWidget.mediaPlayerFuture != widget.mediaPlayerFuture) {
      _currentFuture = widget.mediaPlayerFuture;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _currentFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        late Widget centrolWidget;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data == true) {
            centrolWidget = Video(
              key: ValueKey(widget.mediaId),
              controller: widget.mediaPlayerController.videoController!,
              controls: NoVideoControls,
              fill: CommonColors.color333333,
              resumeUponEnteringForegroundMode: true,
              subtitleViewConfiguration: const SubtitleViewConfiguration(
                style: TextStyle(
                  height: 1.5,
                  fontSize: 40.0,
                  letterSpacing: 0.0,
                  wordSpacing: 0.0,
                  color: Color(0xffffffff),
                  fontWeight: FontWeight.normal,
                  backgroundColor: Color(0xaa000000),
                ),
                padding: EdgeInsets.all(24.0),
              ),
            );
          } else {
            centrolWidget = const SizedBox();
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              Center(child: centrolWidget),
              // Center(child: danmaku),
              Center(
                child: MediaPlayerControlPanel(
                  widget.mediaPlayerController,
                  onToggleFullScreen: (isFullscreen) {},
                  onChooseEpisode: widget.onChooseEpisode,
                  onReload: widget.onReload,
                ),
              ),
            ],
          );
        } else {
          return Center(child: loadingIndicator(size: 30.w, strokeWidth: 2));
        }
      },
    );
  }
}
