import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/modules/v2/home/controllers/multi/media_detail_multi_controller.dart';
import 'package:editvideo/modules/v2/home/widget/multi/auto_scroll_episode_multi_wrapper.dart';
import 'package:editvideo/modules/v2/home/widget/episode_horizontal_cell.dart';
import 'package:editvideo/modules/v2/home/widget/multi/tv_season_multi_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 剧集弹窗(横屏)
class TvSeasonMultiDialog extends StatefulWidget {
  final MediaDetailMultiController controller;

  const TvSeasonMultiDialog({super.key, required this.controller});

  @override
  State<TvSeasonMultiDialog> createState() => _TvSeasonMultiDialogState();
}

class _TvSeasonMultiDialogState extends State<TvSeasonMultiDialog> {
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
          child: TvSeasonMultiView(
            controller: widget.controller,
            isDialog: true,
            needAdapted: false,
            contentBuilder: (context, episodeList) {
              return AutoScrollEpisodeMultiWrapper(
                controller: widget.controller,
                episodeList: episodeList,
                calculateOffset: (index, viewportDimension) {
                  final row = index ~/ 5;
                  final availableWidth = 343.0 - 16.0 * 2; // container width - horizontal padding
                  final itemWidth = (availableWidth - 8.0 * 4) / 5; // minus crossAxisSpacing
                  final itemHeight = itemWidth; // childAspectRatio is 1.0
                  final mainAxisSpacing = 8.0;
                  final paddingTop = 16.0;
                  final itemCenter = paddingTop + row * (itemHeight + mainAxisSpacing) + itemHeight / 2;
                  return itemCenter - viewportDimension / 2;
                },
                builder: (context, scrollController) {
                  return GridView.builder(
                    controller: scrollController,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
