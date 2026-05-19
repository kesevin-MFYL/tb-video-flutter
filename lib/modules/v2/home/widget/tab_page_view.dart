import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/home/widget/media_scroller_view.dart';
import 'package:editvideo/widget/tabbar/common_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabPageView extends StatefulWidget {
  const TabPageView({super.key, required this.mediaList, this.tabBarViewHeight = 200, this.action});

  final List<MediaItemEntity> mediaList;
  final double tabBarViewHeight;
  final void Function(MediaItemEntity mediaItem, SectionType sectionType)? action;

  @override
  State<TabPageView> createState() => _TabPageViewState();
}

class _TabPageViewState extends State<TabPageView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.mediaList.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          child: CommonIndicatorTabBar(
            tabController: _tabController,
            tabBarPadding: EdgeInsets.zero,
            tabs: widget.mediaList,
            isScrollable: true,
          ),
        ),
        SizedBox(
          height: widget.tabBarViewHeight,
          child: TabBarView(
            controller: _tabController,
            children: widget.mediaList.map((mediaItem) {
              final mediaList = mediaItem.dataList ?? [];
              return MediaScrollerView(
                mediaList: mediaList,
                sectionType: SectionType.streamingMedia,
                action: (mediaItem, sectionType) => widget.action?.call(mediaItem, sectionType),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
