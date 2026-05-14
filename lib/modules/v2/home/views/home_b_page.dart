import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/home_b_controller.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeBPage extends StatelessWidget {
  const HomeBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeBController>(
      init: HomeBController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: Stack(
            children: [
              Container(
                height: 110.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonHomeBg)),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText.instance('SearchBar', 20.sp),
                    Expanded(
                      child: CommonRefresh.instance(
                        hasBefore: true,
                        hasMore: false,
                        child: MultiStatusView(
                          hasAppBar: false,
                          currentStatus: controller.multiStatusType,
                          child: CustomScrollView(
                            slivers: controller.homeSectionList.map((section) {
                              final sectionType = SectionType.kind(section.kind);
                              return _buildVideoSection(sectionType, section, controller);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
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

  Widget _buildVideoSection(SectionType sectionType, HomeSectionEntity section, HomeBController controller) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 16.w, top: 32.w, right: 16.w),
      sliver: SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CommonText.instance(section.title ?? '', 14.sp, fontWeight: CommonFontWeight.bold),
                Spacer(),
                CommonButton(
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  spacing: 4.w,
                  suffixDirectional: SuffixDirectional.right,
                  suffixWidget: Image.asset(Assets.commonIconVideoArrowRight, width: 16.w, height: 16.w),
                  onPressed: () => controller.viewAll(section),
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
            SizedBox(height: 12.w),
            _buildSectionSecondary(sectionType, section),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionSecondary(SectionType sectionType, HomeSectionEntity section) {
    switch (sectionType) {
      case SectionType.imdbList: //合集list
        return _buildImdbList(section);
      // case SectionType.mediaList: //单片
      //   return _buildMediaList(section);
      // case SectionType.imdbInterest: //兴趣分类
      //   return _buildImdbInterest(section);
      // case SectionType.streamingmMedia: //渠道
      //   return _buildStreamingmMedia(section);
      default:
        return Container();
    }
  }

  Widget _buildImdbList(HomeSectionEntity section) {
    final dataList = section.dataList ?? [];
    final factor = Get.width / 375;
    final itemWidth = factor * 268;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: dataList.map((mediaItem) {
          final index = dataList.indexOf(mediaItem);
          return Container(
            margin: EdgeInsets.only(right: index != dataList.length - 1 ? 12.w : 0),
            child: CommonButton(
              minSize: 0,
              borderRadius: BorderRadius.circular(24.r),
              color: CommonColors.color1B1B18,
              onPressed: () {},
              child: Container(
                width: itemWidth,
                padding: EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: CommonColors.color222222, width: 1.w),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 80.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: CommonColors.color333333,
                            ),
                            child: CommonImageView.normal(
                              imageUrl: mediaItem.cover,
                              alignment: Alignment.topCenter,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [CommonColors.color060600.withOpacity(0), CommonColors.color060600],
                                ),
                              ),
                              child: CommonButton(
                                minSize: 20.w,
                                alignment: Alignment.centerLeft,
                                borderRadius: BorderRadius.circular(10.r),
                                spacing: 4.w,
                                suffixDirectional: SuffixDirectional.left,
                                suffixWidget: Image.asset(Assets.commonIconVideoList, width: 16.w, height: 16.w),
                                child: CommonText.instance(
                                  'List',
                                  10.sp,
                                  color: CommonColors.white.withOpacity(0.8),
                                  fontWeight: CommonFontWeight.medium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ),

                    SizedBox(height: 12.w),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
