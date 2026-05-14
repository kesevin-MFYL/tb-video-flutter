import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/explore/controllers/explore_controller.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      init: ExploreController(),
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
                        Image.asset(Assets.commonIconHistoryTitle, width: 86.w, height: 48.w),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Image.asset(Assets.commonTabSelected, width: 93.w, height: 18.w),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Center(child: CommonText.instance('Explore Page', 20.sp, fontWeight: CommonFontWeight.bold)),
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
