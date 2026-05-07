import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/common/controllers/web_controller.dart';
import 'package:editvideo/modules/setting/controllers/setting_controller.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      init: SettingController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Stack(
                      children: [
                        Image.asset(Assets.commonIconSettingTitle, width: 95.w, height: 48.w),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Image.asset(Assets.commonTabSelected, width: 93.w, height: 18.w),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                  CommonButton(
                    minSize: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 19.h),
                    borderRadius: BorderRadius.circular(24.r),
                    color: CommonColors.color333333,
                    onPressed: () {
                      Get.toNamed(Routes.webPage, arguments: {
                        'webType': WebViewType.privacyPolicy,
                        'webUrl': 'https://movixweb.com/privacy/',
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(Assets.commonIconPolicy, width: 24.w, height: 24.w),
                        SizedBox(width: 8.w),
                        Expanded(child: CommonText.instance('Policy', 16.sp, fontWeight: CommonFontWeight.semiBold)),
                        Image.asset(Assets.commonArrowRight, width: 24.w, height: 24.w),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  CommonButton(
                    minSize: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 19.h),
                    borderRadius: BorderRadius.circular(24.r),
                    color: CommonColors.color333333,
                    onPressed: () {
                      Get.toNamed(Routes.webPage, arguments: {
                        'webType': WebViewType.userAgreement,
                        'webUrl': 'https://movixweb.com/terms/',
                      });
                    },
                    child: Row(
                      children: [
                        Image.asset(Assets.commonIconUserAgreement, width: 24.w, height: 24.w),
                        SizedBox(width: 8.w),
                        Expanded(child: CommonText.instance('User Agreement', 16.sp, fontWeight: CommonFontWeight.semiBold)),
                        Image.asset(Assets.commonArrowRight, width: 24.w, height: 24.w),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  CommonButton(
                    minSize: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 19.h),
                    borderRadius: BorderRadius.circular(24.r),
                    color: CommonColors.color333333,
                    onPressed: controller.feedback,
                    child: Row(
                      children: [
                        Image.asset(Assets.commonIconFeedBack, width: 24.w, height: 24.w),
                        SizedBox(width: 8.w),
                        Expanded(child: CommonText.instance('Feedback', 16.sp, fontWeight: CommonFontWeight.semiBold)),
                        Image.asset(Assets.commonArrowRight, width: 24.w, height: 24.w),
                      ],
                    ),
                  ),

                  //todo GDPR权限检查
                  // if (controller.isPrivacyOptionsRequired) ...[
                  //   SizedBox(height: 16.h),
                  //   CommonButton(
                  //     minSize: 0,
                  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 19.h),
                  //     borderRadius: BorderRadius.circular(24.r),
                  //     color: CommonColors.color333333,
                  //     onPressed: controller.showPrivacyOptions,
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 24.w),
                  //         SizedBox(width: 8.w),
                  //         Expanded(child: CommonText.instance('Privacy Settings', 16.sp, fontWeight: CommonFontWeight.semiBold)),
                  //         Image.asset(Assets.commonArrowRight, width: 24.w, height: 24.w),
                  //       ],
                  //     ),
                  //   ),
                  // ],

                  SizedBox(height: 16.h),
                  CommonButton(
                    minSize: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 19.h),
                    borderRadius: BorderRadius.circular(24.r),
                    color: CommonColors.color333333,
                    onPressed: () {
                      MobileAds.instance.openAdInspector((error) {
                        // Error will be non-null if ad inspector closed due to an error.
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 24.w),
                        SizedBox(width: 8.w),
                        Expanded(child: CommonText.instance('广告检查器', 16.sp, fontWeight: CommonFontWeight.semiBold)),
                        Image.asset(Assets.commonArrowRight, width: 24.w, height: 24.w),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
