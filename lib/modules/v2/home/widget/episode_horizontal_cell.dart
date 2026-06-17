import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EpisodeHorizontalCell extends StatelessWidget {
  const EpisodeHorizontalCell({
    super.key,
    required this.episodeEntity,
    required this.selected,
    this.width,
    this.height,
    this.needAdapted = true,
    this.action,
    this.isDialog = false,
  });

  final EpisodeEntity episodeEntity;
  final bool selected;
  final bool isDialog;
  final double? width;
  final double? height;
  final bool needAdapted;
  final void Function(EpisodeEntity mediaItem)? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        action?.call(episodeEntity);
      },
      child: Container(
        width: width ?? 48.w,
        height: width ?? 48.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? (isDialog ? CommonColors.color1B1B18.withOpacity(0.5) : CommonColors.color1B1B18) : (isDialog ? CommonColors.white.withOpacity(0.1) : CommonColors.color333333),
          borderRadius: BorderRadius.circular(needAdapted ? 16.r : 16),
          border: selected ? Border.all(color: CommonColors.primaryColor, width: needAdapted ? 1.5.w : 1.5) : null,
        ),
        child: CommonText.instance(
          '${episodeEntity.epsNum}',
          needAdapted ? 14.sp : 14,
          color: selected ? CommonColors.primaryColor : CommonColors.white,
          fontWeight: CommonFontWeight.bold,
        ),
      ),
    );
  }
}
