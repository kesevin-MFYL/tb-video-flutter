import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/modules/v2/home/widget/episode_horizontal_cell.dart';
import 'package:editvideo/modules/v2/home/widget/tv_season_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 剧集弹窗(横屏)
class TvSeasonDialog extends StatefulWidget {
  final MediaDetailController controller;

  const TvSeasonDialog({super.key, required this.controller});

  @override
  State<TvSeasonDialog> createState() => _TvSeasonDialogState();
}

class _TvSeasonDialogState extends State<TvSeasonDialog> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 343,
          margin: EdgeInsets.only(top: 16, bottom: 16, right: 16),
          padding: EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: CommonColors.color1B1B18.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
          ),
          child: TvSeasonView(
            controller: widget.controller,
            isDialog: true,
            needAdapted: false,
            contentBuilder: (context, episodeList) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: episodeList.length,
                itemBuilder: (context, index) {
                  final episodeItem = episodeList[index];
                  return Obx(() {
                    final selectEpisode = widget.controller.selectEpisode.value;
                    return EpisodeHorizontalCell(
                      episodeEntity: episodeItem,
                      selected: selectEpisode == episodeItem,
                      width: double.infinity,
                      height: double.infinity,
                      needAdapted: false,
                      action: (item) {
                        Navigator.of(context).pop();
                        widget.controller.chooseEpisode(item);
                      },
                    );
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
