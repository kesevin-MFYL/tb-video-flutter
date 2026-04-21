import 'dart:io';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum VideoCellType { memory, draft }

class VideoCell extends StatelessWidget {
  const VideoCell({
    super.key,
    required this.memoryInfo,
    required this.videoAction,
    required this.operationAction,
    required this.cellType,
  });

  final MemoryInfo memoryInfo;
  final void Function(MemoryInfo memoryInfo, VideoCellType cellType) videoAction;
  final void Function(MemoryInfo memoryInfo, VideoCellType cellType) operationAction;
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
            CommonButton(
              minSize: 0,
              borderRadius: BorderRadius.zero,
              onPressed: () => videoAction(memoryInfo, cellType),
              child: Container(
                width: double.infinity,
                height: 96.w,
                decoration: BoxDecoration(
                  color: CommonColors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    if (memoryInfo.videoInfo!.thumbnailPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.file(
                          File(memoryInfo.videoInfo!.thumbnailPath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Image.asset(
                                  Assets.commonIconVideoError, width: 80.w, height: 80.w, fit: BoxFit.cover),
                            );
                          },
                        ),
                      ),

                    if (memoryInfo.videoInfo!.thumbnailPath == null)
                      Center(
                        child: Image.asset(Assets.commonIconVideoError, width: 80.w, height: 80.w, fit: BoxFit.cover),
                      )
                    else
                      Center(
                        child: Image.asset(Assets.commonVideoPlay, width: 48.w, height: 48.w),
                      ),
                  ],
                ),
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
                      memoryInfo.title.isEmptyString()
                          ? memoryInfo.videoInfo!.path?.split('/').last ?? ''
                          : memoryInfo.title!,
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
                  onPressed: () => operationAction(memoryInfo, cellType),
                  child: Image.asset(
                    cellType == VideoCellType.memory ? Assets.commonOperationMore : Assets.commonOperationDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
