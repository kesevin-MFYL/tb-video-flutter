import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/widget/media_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SteamingMediaView extends StatefulWidget {
  const SteamingMediaView({super.key, required this.mediaList, required this.itemWidth, required this.imageHeight});

  final List<MediaItemEntity> mediaList;
  final double itemWidth;
  final double imageHeight;

  @override
  State<SteamingMediaView> createState() => _SteamingMediaViewState();
}

class _SteamingMediaViewState extends State<SteamingMediaView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: widget.mediaList.map((subMediaItem) {
          final index = widget.mediaList.indexOf(subMediaItem);
          return MediaCell(
            mediaItem: subMediaItem,
            marginRight: index == widget.mediaList.length - 1 ? 0 : 16.w,
            itemWidth: widget.itemWidth,
            imageHeight: widget.imageHeight,
            buttonBorderRadius: 16.r,
          );
        }).toList(),
      ),
    );
  }
}
