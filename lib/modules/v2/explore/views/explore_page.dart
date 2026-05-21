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

class ExplorePage extends StatelessWidget {
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
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
                      child: NestedScrollView(
                        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            _buildFilter(filterList: controller.genresFilter),
                            _buildFilter(filterList: controller.yearFilter),
                            _buildFilter(filterList: controller.countryFilter),
                          ];
                        },
                        body: CommonRefresh.instance(
                          controller: controller.refreshController,
                          onRefresh: controller.onRefresh,
                          hasMore: controller.hasMore,
                          onLoad: controller.onLoadMore,
                          child: MultiStatusView(
                            hasAppBar: false,
                            currentStatus: controller.multiStatus,
                            action: () {
                              controller.multiStatus = MultiStatusType.statusLoading;
                              controller.onRefresh();
                            },
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
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
                                  itemWidth: double.infinity,
                                  imageHeight: 165.w,
                                  action: (mediaItem) => controller.toMediaPlayPage(mediaItem),
                                );
                              },
                            ),
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

  Widget _buildFilter({required List<String> filterList}) {
    return SliverToBoxAdapter(
      child: filterList.isNotEmpty
          ? SizedBox(
              width: double.infinity,
              height: 24.w,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(indent: 16.w, color: Colors.transparent),
                itemCount: filterList.length,
                itemBuilder: (context, index) {
                  final item = filterList[index];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: CommonColors.color1B1B18,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: CommonText.instance(item, 12.sp, color: CommonColors.white.withOpacity(0.5)),
                    ),
                  );
                },
              ),
            )
          : const SizedBox(),
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
