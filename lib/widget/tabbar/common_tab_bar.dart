import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
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
class CommonIndicatorTabBar extends StatefulWidget {
  const CommonIndicatorTabBar({
    super.key,
    required this.tabs,
    this.tabController,
    this.isScrollable = false,
    this.padding,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  final List<TabBarItem> tabs;

  final TabController? tabController;

  ///是否可滑动
  final bool isScrollable;

  final EdgeInsetsGeometry? padding;

  final TextStyle? selectedTextStyle;

  final TextStyle? unselectedTextStyle;

  @override
  State<CommonIndicatorTabBar> createState() => _CommonIndicatorTabBarState();
}

class _CommonIndicatorTabBarState extends State<CommonIndicatorTabBar> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController ?? TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      tabAlignment: widget.isScrollable ? TabAlignment.start : TabAlignment.center,
      isScrollable: widget.isScrollable,
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorWeight: 0,
      indicator: const BoxDecoration(color: Colors.transparent),
      labelPadding: EdgeInsets.zero,
      tabs: List.generate(widget.tabs.length, (index) {
        return _buildTabItem(widget.tabs[index], index);
      }),
    );
  }

  _buildTabItem(TabBarItem tabBarItem, int index) {
    return Obx(() {
      return Padding(
        padding: widget.padding ?? EdgeInsets.only(left: index != 0 ? 16.w : 0, right: index != widget.tabs.length - 1 ? 16.w : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tabBarItem.tabText,
              style: currentIndex == index ? _getSelectedStyle() : _getUnSelectedStyle(),
            ),
            Image.asset(Assets.commonIconTabIndicator, width: 48.w, height: 12.w),
          ],
        ),
      );
    });
  }

  _getSelectedStyle() {
    return widget.selectedTextStyle ??
        CommonTextStyle.instance(12.sp, color: CommonColors.primaryColor, fontWeight: CommonFontWeight.bold);
  }

  _getUnSelectedStyle() {
    return widget.unselectedTextStyle ??
        CommonTextStyle.instance(12.sp, color: CommonColors.white.withOpacity(0.6), fontWeight: CommonFontWeight.bold);
  }
}
