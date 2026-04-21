import 'dart:io';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/main/controllers/edit_video_controller.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/custom_text_field.dart';
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
          leadingAction: () => controller.toback(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
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

                                  if (controller.isThumbnailLoading)
                                    Center(child: loadingIndicator(size: 24.w, strokeWidth: 1.5))
                                  else if (controller.videoInfo!.thumbnailPath == null)
                                    Center(
                                      child: Image.asset(
                                        Assets.commonIconVideoError,
                                        width: 80.w,
                                        height: 80.w,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Image.asset(Assets.commonVideoPlayBig, width: 48.w, height: 48.w),
                                    ),
                                ],
                              ],
                            ),
                          ),

                          if (controller.videoInfo != null)
                            Positioned(
                              right: -6.w,
                              top: -6.h,
                              child: CommonButton(
                                minSize: 0,
                                borderRadius: BorderRadius.zero,
                                onPressed: () {
                                  controller.deleteVideo();
                                },
                                child: Image.asset(Assets.commonVideoDelete, width: 24.w, height: 24.w),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 52.h),
                      CustomTextField(
                        controller: controller.titleController,
                        hintText: 'Title',
                        prefixIcon: Image.asset(Assets.commonFieldTitle, width: 40.w, height: 40.w),
                        suffixIcon: Image.asset(Assets.commonTakeVideoTips, width: 24.w, height: 24.w),
                        isRequired: true,
                        onChanged: (value) => controller.checkSaveBtnEnabled(),
                      ),

                      SizedBox(height: 30.h),
                      CustomTextField(
                        controller: controller.dateController,
                        hintText: 'Date',
                        prefixIcon: Image.asset(Assets.commonFieldDate, width: 40.w, height: 40.w),
                        suffixIcon: Image.asset(Assets.commonArrowDown, width: 24.w, height: 24.w),
                        isRequired: true,
                        readOnly: true,
                        onTap: controller.showDateTimePicker,
                      ),

                      SizedBox(height: 30.h),
                      CustomTextField(
                        controller: controller.personController,
                        hintText: 'Person',
                        prefixIcon: Image.asset(Assets.commonFieldPerson, width: 40.w, height: 40.w),
                      ),

                      SizedBox(height: 30.h),
                      CustomTextField(
                        controller: controller.memoController,
                        maxLines: null,
                        hintText: 'Memo',
                        prefixIcon: Image.asset(Assets.commonFieldMemo, width: 40.w, height: 40.w),
                      ),

                      SizedBox(height: 22.h),
                    ],
                  ),
                ),
              ),

              Obx(() {
                final enable = controller.saveEnable.value;
                return CommonButton(
                  minSize: 48.h,
                  borderRadius: BorderRadius.zero,
                  disabledColor: CommonColors.color333333,
                  color: CommonColors.primaryColor,
                  suffixDirectional: SuffixDirectional.left,
                  suffixWidget: Image.asset(
                    enable ? Assets.commonSaveEnable : Assets.commonSaveUnenable,
                    width: 24.w,
                    height: 24.w,
                  ),
                  spacing: 8.w,
                  onPressed: enable ? controller.save : null,
                  child: CommonText.instance(
                    'Save',
                    20.sp,
                    color: enable ? CommonColors.color060600 : CommonColors.color666666,
                    fontWeight: CommonFontWeight.bold,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
