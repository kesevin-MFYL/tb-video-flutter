import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaContinueWatchingCell extends StatelessWidget {
  const MediaContinueWatchingCell({super.key, required this.mediaHistoryEntity, this.action});

  final MediaHistoryEntity mediaHistoryEntity;
  final void Function(MediaHistoryEntity mediaHistoryEntity)? action;

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      onPressed: () => action?.call(mediaHistoryEntity),
      child: SizedBox(
        width: 180.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: CommonColors.color333333,
                      border: Border.all(color: CommonColors.color222222, width: 1.w),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CommonImageView.normal(
                        imageUrl: mediaHistoryEntity.cover,
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        height: 101.w,
                        errorWidget: (context, url, error) {
                          return Center(
                            child: Image.asset(Assets.commonMediaPlaceholder, width: 40.w, height: 40.w, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                Image.asset(Assets.commonVideoPlay, width: 32.w, height: 32.w),
              ],
            ),

            SizedBox(height: 12.w),

            CommonText.instance(
              mediaHistoryEntity.title ?? '',
              14.sp,
              fontWeight: CommonFontWeight.medium,
              strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 8.w),
              child: LinearProgressIndicator(
                minHeight: 2.w,
                backgroundColor: CommonColors.color1B1B18,
                color: CommonColors.primaryColor,
                borderRadius: BorderRadius.circular(2),
                value: mediaHistoryEntity.progress,
              ),
            ),

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
                    mediaHistoryEntity.isTv ? Assets.commonIconTv : Assets.commonIconMovie,
                    width: 16.w,
                    height: 16.w,
                  ),

                  if (mediaHistoryEntity.isTv)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: CommonText.instance(
                        '${mediaHistoryEntity.season?.title ?? ''}: Episode ${mediaHistoryEntity.episode?.epsNum ?? 0}',
                        10.sp,
                        color: CommonColors.white.withOpacity(0.8),
                        fontWeight: CommonFontWeight.medium,
                      ),
                    )
                  else if (mediaHistoryEntity.remainingTimeText.isNotEmpty)
                    // 剩余时间观看时间
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: CommonText.instance(
                        mediaHistoryEntity.remainingTimeText,
                        10.sp,
                        color: CommonColors.white.withOpacity(0.8),
                        fontWeight: CommonFontWeight.medium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
