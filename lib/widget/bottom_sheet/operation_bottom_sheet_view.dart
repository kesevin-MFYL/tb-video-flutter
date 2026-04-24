import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';

class OperationBottomSheetView extends StatelessWidget {
  OperationBottomSheetView({super.key, this.editAction, this.deleteAction});

  final VoidCallback? editAction;
  final VoidCallback? deleteAction;

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: safeAreaEdgeInsets.bottom),
      child: Container(
        padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32.h), topRight: Radius.circular(32.h)),
          color: CommonColors.primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CommonButton(
              minSize: 0,
              borderRadius: BorderRadius.zero,
              suffixDirectional: SuffixDirectional.top,
              spacing: 8.h,
              suffixWidget: ClipOval(
                child: Container(
                  color: CommonColors.color060600,
                  alignment: Alignment.center,
                  width: 54.w,
                  height: 54.w,
                  child: Image.asset(Assets.commonVideoEdit, width: 32.w, height: 32.w),
                ),
              ),
              onPressed: () {
                Get.back();
                editAction?.call();
              },
              child: CommonText.instance(
                'Edit',
                14.sp,
                color: CommonColors.color060600,
                fontWeight: CommonFontWeight.bold,
              ),
            ),
            CommonButton(
              minSize: 0,
              borderRadius: BorderRadius.zero,
              suffixDirectional: SuffixDirectional.top,
              spacing: 8.h,
              suffixWidget: ClipOval(
                child: Container(
                  color: CommonColors.colorD43364,
                  alignment: Alignment.center,
                  width: 54.w,
                  height: 54.w,
                  child: Image.asset(Assets.commonVideoDeleteWhite, width: 32.w, height: 32.w),
                ),
              ),
              onPressed: () {
                Get.back();
                deleteAction?.call();
              },
              child: CommonText.instance(
                'Delete',
                14.sp,
                color: CommonColors.color060600,
                fontWeight: CommonFontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show({VoidCallback? editAction, VoidCallback? deleteAction}) {
    Get.bottomSheet(
      OperationBottomSheetView(editAction: editAction, deleteAction: deleteAction),
      barrierColor: CommonColors.black.withOpacity(0.5),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }
}
