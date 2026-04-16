import 'dart:io';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/main/controllers/edit_video_controller.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditVideoPage extends StatelessWidget {
  const EditVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditVideoController>(
      init: EditVideoController(),
      builder: (controller) {
        return PageBase(
          title: 'Edit content',
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: CommonColors.color333333,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: CommonColors.primaryColor, width: 1.w),
                  ),
                  child: Stack(
                    children: [
                      if (controller.videoInfo == null) ...[
                        Center(
                          child: CommonButton(
                            minSize: 0,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            borderRadius: BorderRadius.circular(16.r),
                            color: CommonColors.primaryColor,
                            suffixDirectional: SuffixDirectional.left,
                            spacing: 8.w,
                            suffixWidget: Image.asset(Assets.commonTakeVideo, width: 24.w, height: 24.w),
                            onPressed: () => controller.pickVideo(),
                            child: CommonText.instance(
                              'Upload video',
                              14.sp,
                              color: CommonColors.color060600,
                              fontWeight: CommonFontWeight.semiBold,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 12.w,
                          bottom: 16.h,
                          child: Image.asset(Assets.commonTakeVideoTips, width: 24.w, height: 24.w),
                        ),
                      ] else ...[
                        if (controller.videoInfo!.thumbnailPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Image.file(
                              File(controller.videoInfo!.thumbnailPath!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        if (controller.isThumbnailLoading) Center(child: loadingIndicator(size: 24.w, strokeWidth: 1.5)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
