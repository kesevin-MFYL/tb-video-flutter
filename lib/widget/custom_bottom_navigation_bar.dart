import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.items,
    this.backgroundColor,
    this.decoration,
    this.currentIndex = 0,
    this.showMiddle = true,
    this.onTap,
  });

  final List<BottomNavigationBarItem> items;
  final Color? backgroundColor;
  final Decoration? decoration;
  final int currentIndex;
  final bool? showMiddle;
  final ValueChanged<int>? onTap;

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double additionalBottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: widget.decoration ?? BoxDecoration(color: widget.backgroundColor ?? Colors.transparent),
      child: Padding(
        padding: EdgeInsets.only(bottom: additionalBottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.items.asMap().entries.expand((entry) {
            int index = entry.key;
            BottomNavigationBarItem navigationBarItem = entry.value;
            bool isSelected = widget.currentIndex == index;
            return [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!(index);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      isSelected ? navigationBarItem.activeIcon : navigationBarItem.icon,
                      navigationBarItem.label == null || navigationBarItem.label?.isEmpty == true
                          ? const SizedBox()
                          : CommonText.instance(
                              '${navigationBarItem.label}',
                              12.sp,
                              color: isSelected ? CommonColors.primaryColor : CommonColors.color555555,
                              fontWeight: CommonFontWeight.bold,
                            ),
                    ],
                  ),
                ),
              ),
              if (widget.showMiddle == true && index < widget.items.length - 1) SizedBox(width: 70.w),
            ];
          }).toList(),
        ),
      ),
    );
  }
}
