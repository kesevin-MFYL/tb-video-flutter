import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/home_b_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_cell.dart';
import 'package:editvideo/modules/v2/home/widget/tab_page_view.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeBPage extends StatelessWidget {
  const HomeBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeBController>(
      init: HomeBController(),
      builder: (controller) {
        return VisibilityDetector(
          key: const Key('home_b'),
          onVisibilityChanged: (info) async {
            if (info.visibleFraction > 0.0) {
              controller.getTopPicks(needUpdate: true);
            }
          },
          child: PageBase(
            hasAppBar: false,
            child: Stack(
              children: [
                Container(
                  height: 110.w,
                  decoration: const BoxDecoration(
                    image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonHomeBg)),
                  ),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                        child: Row(
                          children: [
                            Image.asset(Assets.commonIconHomeLogo, width: 32.w, height: 32.w),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: controller.toSearch,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(color: CommonColors.primaryColor, width: 1.w),
                                  ),
                                  child: Row(
                                    children: [
                                      CommonText.instance(
                                        'Search...',
                                        14.sp,
                                        color: CommonColors.white.withOpacity(0.5),
                                        fontWeight: CommonFontWeight.medium,
                                      ),
                                      Spacer(),
                                      Image.asset(Assets.commonIconSearch, width: 24.w, height: 24.w),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CommonRefresh.instance(
                          controller: controller.refreshController,
                          onRefresh: controller.getDataFromServer,
                          hasMore: false,
                          child: MultiStatusView(
                            hasAppBar: false,
                            currentStatus: controller.multiStatusType,
                            actionText: 'Try Again',
                            action: () {},
                            child: CustomScrollView(
                              slivers: [
                                // top picks
                                _buildVideoSection(sectionType: SectionType.topPicks, controller: controller),

                                ...controller.homeSectionList.map((section) {
                                  final sectionType = SectionType.kind(section.kind);
                                  return _buildVideoSection(
                                    sectionType: sectionType,
                                    section: section,
                                    controller: controller,
                                  );
                                }),
                                SliverToBoxAdapter(child: SizedBox(height: 34.w)),
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
          ),
        );
      },
    );
  }

  Widget _buildVideoSection({
    required SectionType sectionType,
    HomeSectionEntity? section,
    required HomeBController controller,
  }) {
    if ((sectionType == SectionType.topPicks && controller.topPicksList.isEmpty) ||
        (sectionType != SectionType.topPicks && section?.dataList == null || section?.dataList!.isEmpty == true)) {
      return SliverToBoxAdapter(child: Container());
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
      sliver: SliverToBoxAdapter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildEmojiAlignedText(
                  sectionType == SectionType.topPicks ? '🎬Top Picks' : section?.title ?? '',
                  style: CommonTextStyle.instance(14.sp, fontWeight: CommonFontWeight.bold),
                ),
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
            _buildSubSection(sectionType: sectionType, section: section, controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection({
    required SectionType sectionType,
    HomeSectionEntity? section,
    required HomeBController controller,
  }) {
    switch (sectionType) {
      case SectionType.imdbList: //合集list
      case SectionType.mediaList: //单片
      case SectionType.topPicks:
      case SectionType.imdbInterest: //兴趣分类
        return _buildHorizontalList(sectionType: sectionType, section: section, controller: controller);
      case SectionType.streamingMedia: //渠道
        return _buildStreamingMedia(section: section, controller: controller);
      default:
        return Container();
    }
  }

  Widget _buildHorizontalList({
    required SectionType sectionType,
    HomeSectionEntity? section,
    required HomeBController controller,
  }) {
    final dataList = sectionType == SectionType.topPicks ? controller.topPicksList : section?.dataList ?? [];
    final factor = Get.width / 375;

    double itemWidth = 0;
    double imageHeight = 0;
    Color? bgColor;
    double? borderRadius;
    EdgeInsetsGeometry? containerPadding;
    bool showBorder = false;
    bool showListOverlay = false;

    if (sectionType == SectionType.imdbList) {
      itemWidth = factor * 268;
      imageHeight = 120.w;
      borderRadius = 24.r;
      bgColor = CommonColors.color1B1B18;
      containerPadding = EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w);
      showBorder = true;
      showListOverlay = true;
    } else if (sectionType == SectionType.mediaList || sectionType == SectionType.topPicks) {
      itemWidth = factor * 110;
      imageHeight = 165.w;
      borderRadius = null;
      bgColor = null;
      containerPadding = null;
      showBorder = false;
      showListOverlay = false;
    } else if (sectionType == SectionType.imdbInterest) {
      itemWidth = factor * 140;
      imageHeight = 80.w;
      borderRadius = 24.r;
      bgColor = CommonColors.color1B1B18;
      containerPadding = EdgeInsets.only(left: 10.w, top: 10.w, right: 10.w, bottom: 12.w);
      showBorder = true;
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
            borderRadius: borderRadius,
            bgColor: bgColor,
            containerPadding: containerPadding,
            showBorder: showBorder,
            showListOverlay: showListOverlay,
            action: (mediaItem) => controller.mediaTap(sectionType, mediaItem),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStreamingMedia({HomeSectionEntity? section, required HomeBController controller}) {
    final factor = Get.width / 375;
    final itemWidth = factor * 110;
    final imageHeight = 165.w;

    final tabBarViewHeight =
        165.w +
        12.w +
        2.w +
        'DISNEY+'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.medium)).height;

    final dataList = section?.dataList ?? [];
    return dataList.isEmpty
        ? Container()
        : TabPageView(
            mediaList: dataList,
            tabBarViewHeight: tabBarViewHeight,
            itemWidth: itemWidth,
            imageHeight: imageHeight,
            action: (mediaItem) => controller.mediaTap(SectionType.streamingMedia, mediaItem),
          );
  }
}
