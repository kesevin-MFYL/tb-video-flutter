import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';

class DeleteSearchHistoryBottomSheet extends StatelessWidget {
  const DeleteSearchHistoryBottomSheet({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: safeAreaEdgeInsets.bottom),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32.h), topRight: Radius.circular(32.h)),
              color: CommonColors.color333333,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: CommonText.instance(
                      'Clear',
                      16.sp,
                      color: CommonColors.primaryColor,
                      fontWeight: CommonFontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  child: CommonText.instance(
                    'Please confirm whether to clear the search history.',
                    14.sp,
                    color: CommonColors.white,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h).copyWith(top: 32.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          minSize: 40.h,
                          borderRadius: BorderRadius.circular(26.r),
                          color: CommonColors.white.withOpacity(0.3),
                          onPressed: () => Get.back(),
                          child: CommonText.instance('Cancel', 16.sp, fontWeight: CommonFontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: CommonButton(
                          minSize: 40.h,
                          borderRadius: BorderRadius.circular(26.r),
                          color: CommonColors.primaryColor,
                          onPressed: () {
                            Get.back();
                            onConfirm();
                          },
                          child: CommonText.instance(
                            'Clear',
                            16.sp,
                            color: CommonColors.color060600,
                            fontWeight: CommonFontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -40.w,
            left: 16.w,
            child: Image.asset(Assets.commonVideoDelete, width: 80.w, height: 80.w, color: CommonColors.primaryColor),
          ),
        ],
      ),
    );
  }

  static void show({required VoidCallback onConfirm}) {
    Get.bottomSheet(
      DeleteSearchHistoryBottomSheet(onConfirm: onConfirm),
      barrierColor: CommonColors.black.withOpacity(0.5),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }
}
