import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/widget/media/media_player_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaPlayerView extends StatefulWidget {
  const MediaPlayerView({super.key, required this.controller, required this.mediaPlayerFuture, this.onReload});

  final MediaDetailController controller;
  final Future<bool> mediaPlayerFuture;
  final VoidCallback? onReload;

  @override
  State<MediaPlayerView> createState() => _MediaPlayerViewState();
}

class _MediaPlayerViewState extends State<MediaPlayerView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.mediaPlayerFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        late Widget centrolWidget;
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data == true) {
            centrolWidget = Video(
              key: ValueKey(widget.controller.mediaId),
              controller: widget.controller.mediaPlayerController.videoController!,
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
                  widget.controller.mediaPlayerController,
                  onToggleFullScreen: (isFullscreen) {},
                  onReload: () {

                  },
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
