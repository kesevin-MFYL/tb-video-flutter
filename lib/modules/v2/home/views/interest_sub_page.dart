import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/home/controllers/interest_sub_controller.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 分类二级页面
class InterestSubPage extends GetView<InterestSubController> {
  const InterestSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InterestSubController>(
      init: InterestSubController(),
      builder: (controller) {
        return PageBase(
          isTransparentAppBar: true,
          title: controller.interestAllEntity.title,
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
                  hasBefore: false,
                  hasMore: false,
                  child: MultiStatusView(
                    currentStatus: MultiStatusType.statusContent,
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15.w,
                        mainAxisSpacing: 15.w,
                        childAspectRatio: 164 / 146,
                      ),
                      itemCount: controller.mediaList.length,
                      itemBuilder: (context, index) {
                        var mediaItem = controller.mediaList[index];
                        return CommonButton(
                          minSize: 0,
                          borderRadius: BorderRadius.zero,
                          onPressed: () => controller.toInterestDetail(mediaItem),
                          child: Container(
                            padding: EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w),
                            decoration: BoxDecoration(
                              color: CommonColors.color1B1B18,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(color: CommonColors.color222222, width: 1.w),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      color: CommonColors.color333333,
                                      border: Border.all(color: CommonColors.color222222, width: 1.w),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: CommonImageView.normal(
                                        imageUrl: mediaItem.cover,
                                        alignment: Alignment.topCenter,
                                        width: double.infinity,
                                        height: 96.w,
                                        errorWidget: (context, url, error) {
                                          return Center(
                                            child: Image.asset(
                                              Assets.commonMediaPlaceholder,
                                              width: 40.w,
                                              height: 40.w,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                CommonText.instance(
                                  mediaItem.title ?? '',
                                  12.sp,
                                  fontWeight: CommonFontWeight.medium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
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
