import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EpisodeVerticalCell extends StatelessWidget {
  const EpisodeVerticalCell({super.key, required this.episodeEntity, required this.selected, this.action});

  final EpisodeEntity episodeEntity;
  final bool selected;
  final void Function(EpisodeEntity mediaItem)? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        action?.call(episodeEntity);
      },
      child: Container(
        height: 48.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: CommonColors.color333333,
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
          border: selected ? Border.all(color: CommonColors.primaryColor, width: 1.5.w) : null,
        ),
        child: Row(
          children: [
            CommonText.instance(
              '${episodeEntity.epsNum}',
              14.sp,
              color: selected ? CommonColors.primaryColor : CommonColors.white,
              fontWeight: CommonFontWeight.bold,
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: CommonText.instance(
                episodeEntity.title ?? '',
                14.sp,
                color: selected ? CommonColors.primaryColor : CommonColors.white,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
