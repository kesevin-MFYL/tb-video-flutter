import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

abstract class TabBarItem {
  String get tabText;

  String? get tabIcon;

  String? get markIcon;
}

///公共的带有指示器tabbar组件
class CommonIndicatorTabBar extends StatelessWidget {
  const CommonIndicatorTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.tabController,
    this.isScrollable = false,
    this.padding,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  final List<TabBarItem> tabs;

  final TabController? tabController;

  final Rx<int> currentIndex;

  ///是否可滑动
  final bool isScrollable;

  final EdgeInsetsGeometry? padding;

  final TextStyle? selectedTextStyle;

  final TextStyle? unselectedTextStyle;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.center,
      isScrollable: isScrollable,
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorWeight: 0,
      indicator: const BoxDecoration(color: Colors.transparent),
      labelPadding: EdgeInsets.zero,
      tabs: List.generate(tabs.length, (index) {
        return _buildTabItem(tabs[index], index);
      }),
    );
  }

  _buildTabItem(TabBarItem tabBarItem, int index) {
    return Obx(() {
      return Padding(
        padding: padding ?? EdgeInsets.only(left: index != 0 ? 10.w : 0, right: index != tabs.length - 1 ? 10.w : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tabBarItem.tabText, style: currentIndex.value == index ? _getSelectedStyle() : _getUnSelectedStyle()),
            Container(
              width: 15.w,
              height: 3.h,
              margin: EdgeInsets.only(top: 5.h),
              color: currentIndex.value == index ? CommonColors.primaryColor : Colors.transparent,
            ),
          ],
        ),
      );
    });
  }

  _getSelectedStyle() {
    return selectedTextStyle ??
        CommonTextStyle.instance(12.sp, color: CommonColors.primaryColor, fontWeight: CommonFontWeight.bold);
  }

  _getUnSelectedStyle() {
    return unselectedTextStyle ??
        CommonTextStyle.instance(12.sp, color: CommonColors.white.withOpacity(0.6), fontWeight: CommonFontWeight.bold);
  }
}
