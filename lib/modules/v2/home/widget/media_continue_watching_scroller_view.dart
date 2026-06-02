import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/modules/v2/home/widget/media_continue_watching_cell.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaContinueWatchingScrollerView extends StatefulWidget {
  const MediaContinueWatchingScrollerView({super.key, required this.mediaList, this.action});

  final List<MediaHistoryEntity> mediaList;
  final void Function(MediaHistoryEntity historyEntity)? action;

  @override
  State<MediaContinueWatchingScrollerView> createState() => _MediaContinueWatchingScrollerViewState();
}

class _MediaContinueWatchingScrollerViewState extends State<MediaContinueWatchingScrollerView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return SizedBox(
      width: double.infinity,
      height: getItemHeight(),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        shrinkWrap: true,
        separatorBuilder: (context, index) => Divider(indent: 12.w, color: Colors.transparent),
        itemCount: widget.mediaList.length,
        itemBuilder: (context, index) {
          final mediaItem = widget.mediaList[index];
          return MediaContinueWatchingCell(mediaHistoryEntity: mediaItem, action: (mediaItem) => widget.action?.call(mediaItem));
        },
      ),
    );
  }

  double getItemHeight() {
    final textHeight = 'Text'.size(style: CommonTextStyle.instance(14.sp, fontWeight: CommonFontWeight.medium)).height;
    return 101.w + 12.w + 2.w + textHeight + 18.w + 20.w;
  }
}
