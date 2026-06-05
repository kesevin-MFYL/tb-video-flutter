import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/interest_all_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_scroller_view.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 合集二级页面
class InterestAllPage extends GetView<InterestAllController> {
  const InterestAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InterestAllController>(
      init: InterestAllController(),
      builder: (controller) {
        return PageBase(
          isTransparentAppBar: true,
          child: Stack(
            children: [
              Container(
                height: 96.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonIconSubTitleBg)),
                ),
              ),
              SafeArea(
                child: CommonRefresh.instance(
                  controller: controller.refreshController,
                  onRefresh: controller.getInterestAllList,
                  hasBefore: controller.hasRefresh,
                  hasMore: false,
                  child: MultiStatusView(
                    currentStatus: controller.multiStatusType,
                    action: () {
                      controller.multiStatusType = MultiStatusType.statusLoading;
                      controller.update();
                      controller.getInterestAllList();
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 16.w),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(height: 36.w, color: Colors.transparent),
                      itemCount: controller.interestAllList.length,
                      itemBuilder: (context, index) {
                        final interestAllItem = controller.interestAllList[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                children: [
                                  buildEmojiAlignedText(
                                    interestAllItem.title ?? '',
                                    style: CommonTextStyle.instance(14.sp, fontWeight: CommonFontWeight.bold),
                                  ),
                                  Spacer(),
                                  CommonButton(
                                    minSize: 0,
                                    borderRadius: BorderRadius.zero,
                                    spacing: 4.w,
                                    suffixDirectional: SuffixDirectional.right,
                                    suffixWidget: Image.asset(
                                      Assets.commonIconVideoArrowRight,
                                      width: 16.w,
                                      height: 16.w,
                                    ),
                                    onPressed: () => controller.viewAll(interestAllItem),
                                    child: CommonText.instance(
                                      'View All',
                                      12.sp,
                                      color: CommonColors.primaryColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: CommonColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12.w),

                            if (interestAllItem.dataList != null && interestAllItem.dataList!.isNotEmpty)
                              MediaScrollerView(
                                mediaList: interestAllItem.dataList!,
                                sectionType: SectionType.imdbInterest,
                                action: controller.toInterestDetail,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
