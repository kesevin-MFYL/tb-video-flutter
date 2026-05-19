import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/widget/media_cell.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaScrollerView extends StatefulWidget {
  const MediaScrollerView({super.key, required this.mediaList, required this.sectionType, this.action});

  final List<MediaItemEntity> mediaList;
  final SectionType sectionType;
  final void Function(MediaItemEntity mediaItem, SectionType sectionType)? action;

  @override
  State<MediaScrollerView> createState() => _MediaScrollerViewState();
}

class _MediaScrollerViewState extends State<MediaScrollerView> with AutomaticKeepAliveClientMixin {
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
          return MediaCell(
            mediaItem: mediaItem,
            itemWidth: itemWidth,
            imageHeight: imageHeight,
            bgColor: bgColor,
            borderRadius: borderRadius,
            containerPadding: padding,
            showBorder: showBorder,
            showListOverlay: showListOverlay,
            action: (mediaItem) => widget.action?.call(mediaItem, widget.sectionType),
          );
        },
      ),
    );
  }

  double getItemHeight() {
    final textHeight = 'Text'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.medium)).height;
    return (widget.sectionType == SectionType.imdbList || widget.sectionType == SectionType.imdbInterest ? 24.w : 0) +
        imageHeight +
        12.w +
        2.w +
        textHeight;
  }

  double get itemWidth => widget.sectionType == SectionType.imdbList
      ? 268.w
      : widget.sectionType == SectionType.imdbInterest
      ? 140.w
      : 110.w;

  double get imageHeight => widget.sectionType == SectionType.imdbList
      ? 120.w
      : widget.sectionType == SectionType.imdbInterest
      ? 80.w
      : 165.w;

  Color? get bgColor => widget.sectionType == SectionType.imdbList || widget.sectionType == SectionType.imdbInterest
      ? CommonColors.color1B1B18
      : null;

  double? get borderRadius =>
      widget.sectionType == SectionType.imdbList || widget.sectionType == SectionType.imdbInterest ? 24.r : null;

  bool get showBorder =>
      widget.sectionType == SectionType.imdbList || widget.sectionType == SectionType.imdbInterest ? true : false;

  bool get showListOverlay => widget.sectionType == SectionType.imdbList ? true : false;

  EdgeInsetsGeometry? get padding =>
      widget.sectionType == SectionType.imdbList || widget.sectionType == SectionType.imdbInterest
      ? EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w)
      : null;
}
