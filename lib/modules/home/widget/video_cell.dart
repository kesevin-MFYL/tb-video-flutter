import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum VideoCellType { memory, draft }

class VideoCell extends StatelessWidget {
  const VideoCell({super.key, required this.videoInfo, required this.action, required this.cellType});

  final String videoInfo;
  final void Function(String videoInfo, VideoCellType cellType) action;
  final VideoCellType cellType;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: CommonColors.color1B1B18,
          border: Border.all(color: CommonColors.color222222, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 96.w,
              decoration: BoxDecoration(
                color: CommonColors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 10.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: CommonText.instance(
                      'PEAKY BLINDERS',
                      14.sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: CommonFontWeight.bold,
                    ),
                  ),
                ),
                CommonButton(
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: () => action(videoInfo, cellType),
                  child: Image.asset(cellType == VideoCellType.memory ? Assets.commonOperationMore : Assets.commonOperationDelete),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
