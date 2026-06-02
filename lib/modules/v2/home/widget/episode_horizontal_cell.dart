import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EpisodeHorizontalCell extends StatelessWidget {
  const EpisodeHorizontalCell({super.key, required this.episodeEntity, required this.selected, this.action});

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
        width: 48.w,
        height: 48.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: CommonColors.color333333,
          borderRadius: BorderRadius.circular(16.4),
          border: selected ? Border.all(color: CommonColors.primaryColor, width: 1.5.w) : null,
        ),
        child: CommonText.instance(
          '${episodeEntity.epsNum}',
          14.sp,
          color: selected ? CommonColors.primaryColor : CommonColors.white,
          fontWeight: CommonFontWeight.bold,
        ),
      ),
    );
  }
}
