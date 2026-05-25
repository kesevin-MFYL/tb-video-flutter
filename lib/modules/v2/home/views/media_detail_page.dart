import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_scroller_view.dart';
import 'package:editvideo/modules/v2/home/widget/tab_page_view.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 影片详情
class MediaDetailPage extends GetView<MediaDetailController> {
  const MediaDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaDetailController>(
      init: MediaDetailController(),
      builder: (controller) {
        return PageBase(
          isTransparentAppBar: true,
          actions: _actionView(),
          child: MultiStatusView(
            currentStatus: controller.multiStatusType,
            action: () {
              controller.multiStatusType = MultiStatusType.statusLoading;
              controller.getDataFromServer();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: safeAreaEdgeInsets.top),

                Container(height: 212.w, color: Colors.orangeAccent),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 主要信息
                        _buildBasicInfo(),

                        // 其他信息
                        _buildOtherInfo(),

                        // 相关推荐
                        ..._buildRecommend(),
                      ],
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

  Widget _buildBasicInfo() {
    if (controller.mediaDetailEntity == null) return Container();
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.instance(controller.mediaDetailEntity?.title ?? '', 16.sp, fontWeight: CommonFontWeight.bold),
          SizedBox(height: 12.w),
          Wrap(
            spacing: 8.w, // 标签之间的水平间距
            runSpacing: 8.h, // 标签之间的垂直间距
            children: [
              if (controller.mediaDetailEntity!.certification.isNotEmptyString())
                _buildTag(tagName: controller.mediaDetailEntity!.certification!),
              if (controller.mediaDetailEntity!.countryString.isNotEmptyString())
                _buildTag(tagName: controller.mediaDetailEntity!.country!),
              if (controller.mediaDetailEntity!.year.isNotEmptyString())
                _buildTag(tagName: controller.mediaDetailEntity!.year!),
            ],
          ),
          SizedBox(height: 12.w),
          if (controller.mediaDetailEntity!.genreList != null && controller.mediaDetailEntity!.genreList!.isNotEmpty)
            CommonText.instance(
              controller.mediaDetailEntity!.genreList!.join(' / '),
              12.sp,
              color: CommonColors.white.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildOtherInfo() {
    if (controller.mediaDetailEntity == null) return Container();
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w, vertical: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.commonIconMediaInfo, width: 24.w, height: 24.w),
              SizedBox(width: 8.w),
              CommonText.instance('INFO', 16.sp, fontWeight: CommonFontWeight.bold),
            ],
          ),
          SizedBox(height: 12.w),
          Row(
            children: [
              Expanded(
                child: CommonText.instance(
                  controller.mediaDetailEntity!.description ?? '',
                  14.sp,
                  color: CommonColors.white.withOpacity(0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CommonButton(
                minSize: 0,
                borderRadius: BorderRadius.zero,
                spacing: 4.w,
                suffixDirectional: SuffixDirectional.right,
                suffixWidget: Image.asset(Assets.commonIconVideoArrowRight, width: 16.w, height: 16.w),
                onPressed: () => controller.viewInfoDetail,
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
        ],
      ),
    );
  }

  List<Widget> _buildRecommend() {
    return controller.recommendList.map((section) {
      final sectionType = SectionType.kind(section.kind);
      return _buildRecommendSection(sectionType: sectionType, section: section);
    }).toList();
  }

  Widget _buildRecommendSection({required SectionType sectionType, required HomeSectionEntity section}) {
    if (section.dataList == null || section.dataList!.isEmpty == true) {
      return const SizedBox();
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: buildEmojiAlignedText(
              section?.title ?? '',
              style: CommonTextStyle.instance(14.sp, fontWeight: CommonFontWeight.bold),
            ),
          ),

          SizedBox(height: 12.w),
          _buildSubSection(sectionType: sectionType, section: section),
        ],
      ),
    );
  }

  Widget _buildSubSection({required SectionType sectionType, required HomeSectionEntity section}) {
    switch (sectionType) {
      case SectionType.imdbList: //合集list
      case SectionType.mediaList: //单片
      case SectionType.imdbInterest: //兴趣分类
        return _buildHorizontalList(sectionType: sectionType, section: section);
      case SectionType.streamingMedia: //渠道
        return _buildStreamingMedia(section: section);
      default:
        return const SizedBox();
    }
  }

  Widget _buildHorizontalList({required SectionType sectionType, required HomeSectionEntity section}) {
    final dataList = section.dataList ?? [];

    return MediaScrollerView(mediaList: dataList, sectionType: sectionType, action: controller.mediaTap);
  }

  Widget _buildStreamingMedia({HomeSectionEntity? section}) {
    final tabBarViewHeight =
        165.w +
        12.w +
        2.w +
        'Text'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.medium)).height;

    final dataList = section?.dataList ?? [];
    return dataList.isEmpty
        ? const SizedBox()
        : TabPageView(mediaList: dataList, tabBarViewHeight: tabBarViewHeight, action: controller.mediaTap);
  }

  _buildTag({required String tagName}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: CommonColors.color84705C.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CommonText.instance(
        tagName,
        12.sp,
        color: CommonColors.white.withOpacity(0.8),
        fontWeight: CommonFontWeight.medium,
      ),
    );
  }

  _actionView() {
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Image.asset(Assets.commonIconDanmuControlOpen, width: 24.w, height: 24.w),
    );
  }
}
