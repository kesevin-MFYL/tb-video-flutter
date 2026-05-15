import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:editvideo/widget/tabbar/common_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SteamingMediaView extends StatefulWidget {
  const SteamingMediaView({
    super.key,
    required this.tabController,
    required this.mediaItems,
    required this.itemWidth,
    required this.imageHeight,
    required this.tabBarViewHeight,
  });

  final TabController tabController;
  final List<MediaItemEntity> mediaItems;
  final double itemWidth;
  final double imageHeight;
  final double tabBarViewHeight;

  @override
  State<SteamingMediaView> createState() => _SteamingMediaViewState();
}

class _SteamingMediaViewState extends State<SteamingMediaView>
    with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return DefaultTabController(
      length: widget.mediaItems.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.w),
            child: CommonIndicatorTabBar(
              tabController: widget.tabController,
              tabBarPadding: EdgeInsets.zero,
              tabs: widget.mediaItems,
              isScrollable: true,
            ),
          ),
          SizedBox(
            height: widget.tabBarViewHeight,
            child: TabBarView(
              controller: widget.tabController,
              children: widget.mediaItems.map((mediaItem) {
                final mediaList = mediaItem.dataList ?? [];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  child: Row(
                    children: mediaList.map((subMediaItem) {
                      final index = mediaList.indexOf(subMediaItem);
                      return Container(
                        margin: EdgeInsets.only(right: index != mediaList.length - 1 ? 12.w : 0),
                        child: CommonButton(
                          minSize: 0,
                          borderRadius: BorderRadius.circular(16.r),
                          onPressed: () {},
                          child: Container(
                            width: widget.itemWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: CommonColors.color222222, width: 1.w),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    width: double.infinity,
                                    height: widget.imageHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.r),
                                      color: CommonColors.color333333,
                                    ),
                                    child: CommonImageView.normal(
                                      imageUrl: subMediaItem.cover,
                                      alignment: Alignment.topCenter,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 12.w),
                                CommonText.instance(
                                  subMediaItem.title ?? '',
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
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}