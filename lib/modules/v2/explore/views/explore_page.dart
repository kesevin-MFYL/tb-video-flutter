import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/explore/controllers/explore_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_cell.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExplorePage extends GetView<ExploreController> {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      init: ExploreController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: Stack(
            children: [
              Container(
                height: 128.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonIconSearchBg)),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // search bar
                    Padding(
                      padding: EdgeInsets.only(left: 16.w, top: 12.w, right: 16.w, bottom: 8.w),
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
                                'Search account password',
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

                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification is ScrollUpdateNotification && notification.metrics.axis == Axis.vertical) {
                            if (controller.popShowing.value) {
                              controller.popShowing.value = false;
                            }
                          }
                          return false;
                        },
                        child: Stack(
                          children: [
                            NestedScrollView(
                              controller: controller.scrollController,
                              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                                return <Widget>[
                                  SliverToBoxAdapter(
                                    child: SizedBox(height: 8.w),
                                  ),

                                  _buildFilter(
                                    filterList: controller.typeFilter,
                                    mediaFilterType: MediaFilterType.mediaType,
                                  ),
                                  _buildFilter(
                                    filterList: controller.genresFilter,
                                    mediaFilterType: MediaFilterType.genres,
                                  ),
                                  _buildFilter(
                                    filterList: controller.yearFilter,
                                    mediaFilterType: MediaFilterType.year,
                                  ),
                                  _buildFilter(
                                    filterList: controller.countryFilter,
                                    mediaFilterType: MediaFilterType.country,
                                  ),
                                ];
                              },
                              body: CommonRefresh.instance(
                                controller: controller.refreshController,
                                onRefresh: controller.onRefresh,
                                hasBefore: controller.hasRefresh,
                                hasMore: controller.hasMore,
                                onLoad: controller.hasRefresh ? controller.onLoadMore : null,
                                child: MultiStatusView(
                                  hasAppBar: false,
                                  currentStatus: controller.multiStatus,
                                  action: () {
                                    controller.onRefresh(showLoading: true);
                                  },
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(left: 16.w, top: 4.w, right: 16.w, bottom: 16.w),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8.w,
                                      mainAxisSpacing: 16.w,
                                      childAspectRatio: _getRatio(),
                                    ),
                                    itemCount: controller.mediaList.length,
                                    itemBuilder: (context, index) {
                                      var mediaItem = controller.mediaList[index];
                                      return MediaCell(
                                        mediaItem: mediaItem,
                                        imageHeight: 165.w,
                                        action: (mediaItem) {
                                          controller.toMediaDetailSinglePage(mediaId: mediaItem.id, mediaType: mediaItem.type);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            Positioned(top: 0, left: 0, right: 0, child: _buildFilterTotal()),

                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Obx(() {
                                return controller.popShowing.value ? _buildFilterPop() : const SizedBox();
                              }),
                            ),
                          ],
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
                    height: 32.h,
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

  Widget _buildFilter({required List<String> filterList, required MediaFilterType mediaFilterType}) {
    return SliverToBoxAdapter(
      child: _buildFilterItem(filterList: filterList, mediaFilterType: mediaFilterType),
    );
  }

  Widget _buildFilterItem({required List<String> filterList, required MediaFilterType mediaFilterType}) {
    return filterList.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(bottom: 12.w),
            child: SizedBox(
              width: double.infinity,
              height: 28.w,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shrinkWrap: true,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemCount: filterList.length,
                itemBuilder: (context, index) {
                  final item = filterList[index];
                  return Obx(() {
                    final selectedIndex = controller.getSelectedIndex(mediaFilterType);
                    final isSelected = index == selectedIndex;
                    return GestureDetector(
                      onTap: () {
                        controller.changeFilter(index, mediaFilterType);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: isSelected ? CommonColors.primaryColor.withOpacity(0.15) : CommonColors.color1B1B18,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: CommonText.instance(
                          item,
                          12.sp,
                          color: isSelected ? CommonColors.primaryColor : CommonColors.white.withOpacity(0.5),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildFilterTotal() {
    return Obx(() {
      if (!controller.showFilterTotal.value /*|| controller.popShowing.value*/) return const SizedBox();
      final names = controller.selectedFilterNames;
      if (names.isEmpty) return const SizedBox();

      final text = names.join(' · ');

      return GestureDetector(
        onTap: () {
          controller.popShowing.value = true;
        },
        child: Container(
          color: CommonColors.background,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
          child: Row(
            children: [
              Expanded(
                child: CommonText.instance(
                  text,
                  12.sp,
                  color: CommonColors.white.withOpacity(0.5),
                  strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Image.asset(Assets.commonIconFilterArrowDown, width: 16.w, height: 16.w),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterPop() {
    return ClipRect(
      child: TweenAnimationBuilder<Offset>(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        tween: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero),
        builder: (context, offset, child) {
          return FractionalTranslation(
            translation: offset,
            child: child,
          );
        },
        child: Container(
          color: CommonColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.w),
              _buildFilterItem(filterList: controller.typeFilter, mediaFilterType: MediaFilterType.mediaType),
              _buildFilterItem(filterList: controller.genresFilter, mediaFilterType: MediaFilterType.genres),
              _buildFilterItem(filterList: controller.yearFilter, mediaFilterType: MediaFilterType.year),
              _buildFilterItem(filterList: controller.countryFilter, mediaFilterType: MediaFilterType.country),
            ],
          ),
        ),
      ),
    );
  }

  double _getRatio() {
    final height =
        164 +
            8 +
            2 +
            'The Hobbit'.size(style: CommonTextStyle.instance(13.sp, fontWeight: CommonFontWeight.medium)).height;
    return 109 / height;
  }
}
