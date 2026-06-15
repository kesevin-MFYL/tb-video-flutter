import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/episode_index_controller.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EpisodeIndexView extends StatefulWidget {
  const EpisodeIndexView({
    super.key,
    required this.seasonEntity,
    required this.mediaId,
    this.scrollDirection = Axis.vertical,
    this.scrollerController,
    this.action,
  });

  final SeasonEntity seasonEntity;
  final Axis scrollDirection;
  final int mediaId;
  final ScrollController? scrollerController;
  final void Function(EpisodeEntity episodeEntity)? action;

  @override
  State<EpisodeIndexView> createState() => _EpisodeIndexViewState();
}

class _EpisodeIndexViewState extends State<EpisodeIndexView> with AutomaticKeepAliveClientMixin {
  late EpisodeIndexController controller;
  late ScrollController _scrollerController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      EpisodeIndexController(seasonEntity: widget.seasonEntity, mediaId: widget.mediaId),
      tag: '${widget.seasonEntity.id ?? 0}',
    );

    _scrollerController = widget.scrollerController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollerController == null) {
      _scrollerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EpisodeIndexController>(
      tag: '${widget.seasonEntity.id ?? 0}',
      builder: (logic) {
        return MultiStatusView(
          currentStatus: controller.multiStatusType,
          action: controller.reload,
          hasAppBar: false,
          loadingWidget: widget.scrollDirection == Axis.vertical ? null : loadingIndicator(size: 30.w, strokeWidth: 2),
          child: widget.scrollDirection == Axis.vertical ? _buildVertical() : _buildHorizontal(),
        );
      },
    );
  }

  Widget _buildVertical() {
    return ListView.separated(
      controller: _scrollerController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(height: 16.w, color: Colors.transparent),
      itemCount: controller.episodeList.length,
      itemBuilder: (context, index) {
        final episodeItem = controller.episodeList[index];
        return Obx(() {
          final selectEpisode = controller.mediaDetailController.selectEpisode.value;
          return GestureDetector(
            onTap: () => widget.action?.call(episodeItem),
            child: Container(
              height: 48.w,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: CommonColors.color333333,
                borderRadius: BorderRadius.all(Radius.circular(16.r)),
                border: selectEpisode == episodeItem
                    ? Border.all(color: CommonColors.primaryColor, width: 1.5.w)
                    : null,
              ),
              child: Row(
                children: [
                  CommonText.instance(
                    '${episodeItem.epsNum}',
                    14.sp,
                    color: selectEpisode == episodeItem ? CommonColors.primaryColor : CommonColors.white,
                    fontWeight: CommonFontWeight.bold,
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: CommonText.instance(
                      episodeItem.title ?? '',
                      14.sp,
                      color: selectEpisode == episodeItem ? CommonColors.primaryColor : CommonColors.white,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildHorizontal() {
    return ListView.separated(
      controller: _scrollerController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(indent: 8.w, color: Colors.transparent),
      itemCount: controller.episodeList.length,
      itemBuilder: (context, index) {
        final episodeItem = controller.episodeList[index];
        return Obx(() {
          final selectEpisode = controller.mediaDetailController.selectEpisode.value;
          return GestureDetector(
            onTap: () => widget.action?.call(episodeItem),
            child: Container(
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CommonColors.color333333,
                borderRadius: BorderRadius.circular(16.4),
                border: selectEpisode == episodeItem
                    ? Border.all(color: CommonColors.primaryColor, width: 1.5.w)
                    : null,
              ),
              child: CommonText.instance(
                '${episodeItem.epsNum}',
                14.sp,
                color: selectEpisode == episodeItem ? CommonColors.primaryColor : CommonColors.white,
                fontWeight: CommonFontWeight.bold,
              ),
            ),
          );
        });
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
