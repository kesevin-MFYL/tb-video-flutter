import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/interest_detail_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_scroller_view.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 分类详情
class InterestDetailPage extends GetView<InterestDetailController> {
  const InterestDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InterestDetailController>(
      init: InterestDetailController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          title: controller.interestDetailEntity?.title,
          child: MultiStatusView(
            hasAppBar: false,
            currentStatus: controller.multiStatusType,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CommonImageView.normal(
                      imageUrl: controller.interestDetailEntity?.cover,
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      height: 250.w,
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

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 96.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, CommonColors.color060600],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(top: 0, left: 0, right: 0, child: _titleView()),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          height: 96.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, CommonColors.color060600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    slivers: [
                      _buildTitle(),

                      if (controller.interestDetailEntity != null &&
                          controller.interestDetailEntity!.dataList != null &&
                          controller.interestDetailEntity!.dataList!.isNotEmpty == true)
                        SliverList.separated(
                          separatorBuilder: (context, index) => Divider(height: 32.w, color: Colors.transparent),
                          itemCount: controller.interestDetailEntity!.dataList!.length,
                          itemBuilder: (context, index) {
                            final homeSectionEntity = controller.interestDetailEntity!.dataList![index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Row(
                                    children: [
                                      buildEmojiAlignedText(
                                        homeSectionEntity.title ?? '',
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
                                        onPressed: () => controller.viewAll(homeSectionEntity),
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

                                if (homeSectionEntity.dataList != null && homeSectionEntity.dataList!.isNotEmpty)
                                  MediaScrollerView(
                                    mediaList: homeSectionEntity.dataList!,
                                    sectionType: SectionType.mediaList,
                                    action: (media, sectionType) {
                                      controller.toMediaDetailMultiPage(mediaId: media.id, mediaType: media.type);
                                    },
                                  ),
                              ],
                            );
                          },
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 16.w)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, top: 8.w, right: 16.w, bottom: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(Assets.commonFieldTitle, width: 32.w, height: 32.w),
                SizedBox(width: 4.w),
                CommonText.instance(
                  controller.interestDetailEntity?.title ?? '',
                  20.sp,
                  fontWeight: CommonFontWeight.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            SizedBox(height: 4.w),

            CommonText.instance(
              controller.interestDetailEntity?.description ?? '',
              14.sp,
              color: CommonColors.white.withOpacity(0.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 动态标题
  _titleView() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: safeAreaEdgeInsets.top + 10.w, right: 16.w, bottom: 10.w),
      child: Row(
        children: [
          CommonButton(
            minSize: 32.w,
            onPressed: Get.back,
            child: Image.asset(Assets.commonNavBack, width: 32.w, height: 32.w),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Obx(() {
              final opacity = controller.opacity.value;
              return Opacity(
                opacity: opacity,
                child: CommonText.instance(
                  controller.interestDetailEntity?.title ?? '',
                  16.sp,
                  fontWeight: CommonFontWeight.bold,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
          SizedBox(width: 42.w),
        ],
      ),
    );
  }
}
