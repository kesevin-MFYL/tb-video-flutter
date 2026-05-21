import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/history/controllers/history_controller.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryController>(
      init: HistoryController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 72.w,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Obx(() {
                    final isEdit = controller.isEdit.value;
                    return Row(
                      children: [
                        !isEdit
                            ? Stack(
                                children: [
                                  Image.asset(Assets.commonIconHistoryTitle, width: 86.w, height: 48.w),
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: Image.asset(Assets.commonTabSelected, width: 93.w, height: 18.w),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(Assets.commonIconUnselected, width: 24.w, height: 24.w),
                                    SizedBox(width: 8.w),
                                    CommonText.instance('All', 16.sp, fontWeight: CommonFontWeight.medium),
                                  ],
                                ),
                              ),

                        Spacer(),

                        GestureDetector(
                          onTap: controller.changeEdit,
                          child: !isEdit
                              ? Image.asset(Assets.commonIconHistoryEdit, width: 32.w, height: 32.w)
                              : CommonText.instance('Cancel', 16.sp, fontWeight: CommonFontWeight.medium),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
