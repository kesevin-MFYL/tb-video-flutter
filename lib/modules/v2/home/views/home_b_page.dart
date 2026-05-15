import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/home_b_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_cell.dart';
import 'package:editvideo/modules/v2/home/widget/steaming_media_view.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:editvideo/widget/tabbar/common_tab_bar.dart';
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
                            slivers: [
                              ...controller.homeSectionList.map((section) {
                                final sectionType = SectionType.kind(section.kind);
                                return _buildVideoSection(sectionType, section, controller);
                              }),
                              SliverToBoxAdapter(child: SizedBox(height: 50.w)),
                            ],
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
                if (sectionType == SectionType.mediaList || sectionType == SectionType.imdbInterest)
                  CommonButton(
                    minSize: 0,
                    borderRadius: BorderRadius.zero,
                    spacing: 4.w,
                    suffixDirectional: SuffixDirectional.right,
                    suffixWidget: Image.asset(Assets.commonIconVideoArrowRight, width: 16.w, height: 16.w),
                    onPressed: () => controller.viewAll(sectionType, section),
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
            _buildSubSection(sectionType, section, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(SectionType sectionType, HomeSectionEntity section, HomeBController controller) {
    switch (sectionType) {
      case SectionType.imdbList: //合集list
      case SectionType.mediaList: //单片
      case SectionType.imdbInterest: //兴趣分类
        return _buildHorizontalList(sectionType, section, controller);
      case SectionType.streamingMedia: //渠道
        return _buildStreamingMedia(section, controller);
      default:
        return Container();
    }
  }

  Widget _buildHorizontalList(SectionType sectionType, HomeSectionEntity section, HomeBController controller) {
    final dataList = section.dataList ?? [];
    final factor = Get.width / 375;

    double itemWidth = 0;
    double imageHeight = 0;
    double buttonBorderRadius = 16.r;
    Color? bgColor;
    EdgeInsetsGeometry? containerPadding;
    bool showListOverlay = false;

    if (sectionType == SectionType.imdbList) {
      itemWidth = factor * 268;
      imageHeight = 120.w;
      buttonBorderRadius = 24.r;
      bgColor = CommonColors.color1B1B18;
      containerPadding = EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w);
      showListOverlay = true;
    } else if (sectionType == SectionType.mediaList) {
      itemWidth = factor * 110;
      imageHeight = 165.w;
      buttonBorderRadius = 16.r;
      bgColor = null;
      containerPadding = null;
      showListOverlay = false;
    } else if (sectionType == SectionType.imdbInterest) {
      itemWidth = factor * 140;
      imageHeight = 80.w;
      buttonBorderRadius = 24.r;
      bgColor = CommonColors.color1B1B18;
      containerPadding = EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w);
      showListOverlay = false;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: dataList.map((mediaItem) {
          final index = dataList.indexOf(mediaItem);
          return MediaCell(
            mediaItem: mediaItem,
            marginRight: index == dataList.length - 1 ? 0 : 16.w,
            itemWidth: itemWidth,
            imageHeight: imageHeight,
            buttonBorderRadius: buttonBorderRadius,
            bgColor: bgColor,
            containerPadding: containerPadding,
            showListOverlay: showListOverlay,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStreamingMedia(HomeSectionEntity section, HomeBController controller) {
    final factor = Get.width / 375;
    final itemWidth = factor * 110;
    final imageHeight = 165.w;

    final tabBarViewHeight =
        165.w +
        12.w +
        2.w +
        'DISNEY+'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.medium)).height;

    final dataList = section.dataList ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.w),
          child: CommonIndicatorTabBar(
            tabController: controller.tabController,
            tabBarPadding: EdgeInsets.zero,
            tabs: dataList,
            isScrollable: true,
          ),
        ),
        SizedBox(
          height: tabBarViewHeight,
          child: TabBarView(
            controller: controller.tabController,
            children: dataList.map((mediaItem) {
              final mediaList = mediaItem.dataList ?? [];
              return SteamingMediaView(
                mediaList: mediaList,
                itemWidth: itemWidth,
                imageHeight: imageHeight,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
