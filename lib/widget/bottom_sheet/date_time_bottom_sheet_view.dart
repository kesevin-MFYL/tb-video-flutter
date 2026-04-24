import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/picker/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';

class DateTimeBottomSheetView extends StatelessWidget {
  DateTimeBottomSheetView({super.key, this.initialDate, this.onChanged});

  final DateTime? initialDate;
  final ValueChanged<DateTime>? onChanged;

  DateTime? selectedDate;

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
                      'Select date',
                      16.sp,
                      color: CommonColors.primaryColor,
                      fontWeight: CommonFontWeight.bold,
                    ),
                  ),
                ),
                DatePickerWidget(
                  onChanged: (time) {
                    selectedDate = time;
                  },
                  initialDate: initialDate,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                            onChanged?.call(selectedDate ?? DateTime.now());
                            Get.back();
                          },
                          child: CommonText.instance(
                            'Confirm',
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
            child: Image.asset(Assets.commonIconDatePicker, width: 80.w, height: 80.w),
          ),
        ],
      ),
    );
  }

  static void show({DateTime? initialDate, ValueChanged<DateTime>? onChanged}) {
    Get.bottomSheet(
      DateTimeBottomSheetView(initialDate: initialDate, onChanged: onChanged),
      barrierColor: CommonColors.black.withOpacity(0.3),
      ignoreSafeArea: true,
      isScrollControlled: true,
    );
  }
}
