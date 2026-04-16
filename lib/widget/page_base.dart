import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/constant.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'button/common_button.dart';

enum NavLeadingType { none, back, custom }

class PageBase extends StatefulWidget {
  PageBase({
    super.key,
    this.scaffoldKey,
    this.hasAppBar = true,
    this.isTransparentAppBar = false,
    this.isCenterTitle = true,
    this.leadingType = NavLeadingType.back,
    this.leadingAction,
    this.leading,
    this.leadingWidth,
    this.backIconColor,
    this.titleView,
    this.title,
    this.titleTextColor,
    this.titleTextSize,
    this.actions,
    this.bottom,
    this.backgroundColor = CommonColors.background,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
    this.onBackgroundTap,
    this.systemOverlayStyle,
    required this.child,
    Color? appBarColor,
    double? toolbarHeight,
  }) : appBarColor = appBarColor ?? CommonColors.appBarColor,
       toolbarHeight = toolbarHeight ?? kAppbarHeight.h;

  final Key? scaffoldKey;

  final bool hasAppBar;

  final bool isTransparentAppBar;

  final bool isCenterTitle;

  final double toolbarHeight;

  final Color appBarColor;

  final Widget? titleView;

  final String? title;

  final Color? titleTextColor;

  final double? titleTextSize;

  final Color? backgroundColor;

  final bool extendBodyBehindAppBar;

  final bool? resizeToAvoidBottomInset;

  final Widget child;

  final double? leadingWidth;

  final NavLeadingType leadingType;

  final VoidCallback? leadingAction;

  final Widget? leading;

  final Color? backIconColor;

  final Widget? actions;

  final PreferredSize? bottom;

  final Widget? bottomNavigationBar;

  final SystemUiOverlayStyle? systemOverlayStyle;

  final void Function()? onBackgroundTap;

  @override
  State<PageBase> createState() => _PageBaseState();
}

class _PageBaseState extends State<PageBase> {
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: widget.hasAppBar && !widget.isTransparentAppBar ? widget.extendBodyBehindAppBar : true,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomNavigationBar,
      appBar: widget.hasAppBar
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: widget.toolbarHeight,
              backgroundColor: widget.isTransparentAppBar ? Colors.transparent : CommonColors.appBarColor,
              leadingWidth: widget.leadingWidth,
              leading: _leading(),
              actions: _action(),
              title: _titleView(),
              centerTitle: widget.isCenterTitle,
              bottom: widget.bottom,
              systemOverlayStyle: widget.systemOverlayStyle,
            )
          : AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 0,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: widget.systemOverlayStyle,
            ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (FocusManager.instance.primaryFocus?.hasFocus == true) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          widget.onBackgroundTap?.call();
        },
        child: widget.child,
      ),
    );
  }

  Widget? _leading() {
    switch (widget.leadingType) {
      case NavLeadingType.none:
        return null;
      case NavLeadingType.back:
        return CommonButton(
          minSize: 32.w,
          onPressed: widget.leadingAction ?? Get.back,
          child: Image.asset(
            Assets.commonNavBack,
            color: widget.backIconColor,
            width: 32.w,
            height: 32.w,
          ),
        );
      case NavLeadingType.custom:
        return widget.leading;
    }
  }

  Widget? _titleView() {
    return widget.titleView ??
        (widget.title == null
            ? null
            : CommonText.instance(
                widget.title!,
                widget.titleTextSize ?? 16.sp,
                color: widget.titleTextColor ?? CommonColors.appBarTextColor,
                fontWeight: CommonFontWeight.bold,
              ));
  }

  List<Widget> _action() {
    return widget.actions == null ? [] : [Center(child: widget.actions!), SizedBox(width: 16.w)];
  }
}
