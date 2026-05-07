import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/launch/controllers/launch_controller.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LaunchController>(
      init: LaunchController(),
      builder: (logic) {
        return PageBase(
          hasAppBar: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: safeAreaTopDistance(216.h), child: Image.asset(Assets.commonLaunchIcon)),
              Positioned(left: 0, right: 0, bottom: 0, child: Image.asset(Assets.commonLaunchBg)),
              Positioned(
                bottom: 102.h,
                left: 100.w,
                right: 100.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 4.h,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: logic.progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(CommonColors.primaryColor), // 进度条的黄色
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    CommonText.instance('Loading...', 14.sp, color: CommonColors.white.withOpacity(0.5), fontWeight: CommonFontWeight.medium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
