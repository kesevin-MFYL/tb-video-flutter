import 'dart:async';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HistoryMediaCell extends StatefulWidget {
  const HistoryMediaCell({
    super.key,
    required this.mediaHistoryEntity,
    required this.isEdit,
    required this.isSelected,
    required this.toggleAction,
    required this.tapAction,
    required this.deleteAction,
  });

  final MediaHistoryEntity mediaHistoryEntity;
  final bool isEdit;
  final bool isSelected;
  final void Function(MediaHistoryEntity mediaItem) toggleAction;
  final void Function(MediaHistoryEntity mediaItem) tapAction;
  final void Function(MediaHistoryEntity mediaItem) deleteAction;

  @override
  State<HistoryMediaCell> createState() => _HistoryMediaCellState();
}

class _HistoryMediaCellState extends State<HistoryMediaCell> with SingleTickerProviderStateMixin {
  late SlidableController slidableController = SlidableController(this);

  late StreamSubscription<EventBusModel> _historyEditSubscription;

  @override
  void initState() {
    super.initState();
    _historyEditSubscription = EventBusManager.instance.addObserver(EventBusName.historyEdit, (value) async {
      if (value is bool && value) {
        slidableController.close();
      }
    });
  }

  @override
  void dispose() {
    _historyEditSubscription.cancel();
    slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(widget.mediaHistoryEntity.id.toString()),
      controller: slidableController,
      enabled: !widget.isEdit,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 84 / 375,
        children: [
          CustomSlidableAction(
            borderRadius: BorderRadius.zero,
            padding: EdgeInsets.only(bottom: 16.w, right: 16.w),
            onPressed: (context) => widget.deleteAction(widget.mediaHistoryEntity),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            child: Container(
              height: 68.w,
              decoration: BoxDecoration(color: CommonColors.primaryColor, borderRadius: BorderRadius.circular(24.r)),
              child: Center(
                child: Image.asset(Assets.commonIconHistoryDeleteLarge, width: 32.w, height: 32.w),
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (widget.isEdit) {
            widget.toggleAction(widget.mediaHistoryEntity);
          } else {
            widget.tapAction(widget.mediaHistoryEntity);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          margin: EdgeInsets.only(bottom: 16.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isEdit)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Center(
                      child: Image.asset(
                        widget.isSelected ? Assets.commonIconSelected : Assets.commonIconUnselected,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CommonImageView.normal(
                    imageUrl: widget.mediaHistoryEntity.cover,
                    alignment: Alignment.topCenter,
                    width: 120.w,
                    height: 68.w,
                    errorWidget: (context, url, error) {
                      return Center(
                        child: Image.asset(Assets.commonMediaPlaceholder, width: 40.w, height: 40.w, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.instance(
                        widget.mediaHistoryEntity.title ?? '',
                        14.sp,
                        fontWeight: CommonFontWeight.medium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 20.w,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: CommonColors.color84705C.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  widget.mediaHistoryEntity.isTv ? Assets.commonIconTv : Assets.commonIconMovie,
                                  width: 16.w,
                                  height: 16.w,
                                ),

                                if (widget.mediaHistoryEntity.isTv)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: CommonText.instance(
                                      '${widget.mediaHistoryEntity.season?.title ?? ''}: Episode ${widget.mediaHistoryEntity.episode?.epsNum ?? 0}',
                                      10.sp,
                                      color: CommonColors.white.withOpacity(0.8),
                                      fontWeight: CommonFontWeight.medium,
                                    ),
                                  )
                                else if (widget.mediaHistoryEntity.remainingTimeText.isNotEmpty)
                                  // 剩余时间观看时间
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    child: CommonText.instance(
                                      widget.mediaHistoryEntity.remainingTimeText,
                                      10.sp,
                                      color: CommonColors.white.withOpacity(0.8),
                                      fontWeight: CommonFontWeight.medium,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          Spacer(),

                          // 观看进度
                          if (widget.mediaHistoryEntity.progressText.isNotEmpty)
                            CommonText.instance(
                              widget.mediaHistoryEntity.progressText,
                              12.sp,
                              color: CommonColors.primaryColor.withOpacity(0.5),
                              fontWeight: CommonFontWeight.medium,
                            ),
                        ],
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
  }
}
