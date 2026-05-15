import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/constant.dart' show kAppbarHeight;

enum EmptyActionType {
  /// 只显示文字
  text,

  /// 只显示按钮
  button,

  /// 按钮文字都显示
  all,
}

enum MultiStatusType {
  ///内容
  statusContent,

  ///加载中
  statusLoading,

  ///无数据
  statusEmpty,

  ///数据错误
  statusError,
}

class MultiStatusView extends StatefulWidget {
  const MultiStatusView({
    super.key,
    required this.child,
    this.currentStatus = MultiStatusType.statusContent,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.emptyText,
    this.emptyActionType = EmptyActionType.text,
    this.hasAppBar = true,
    this.backgroundColor,
    this.action,
    this.actionText,
  });

  final Widget child;
  final MultiStatusType currentStatus;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  final Widget? emptyWidget;
  final EmptyActionType emptyActionType;
  final String? emptyText;

  final VoidCallback? action;
  final String? actionText;

  final bool hasAppBar;

  final Color? backgroundColor;

  @override
  State<MultiStatusView> createState() => _MultiStatusViewState();
}

class _MultiStatusViewState extends State<MultiStatusView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (widget.currentStatus) {
      case MultiStatusType.statusContent:
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(color: widget.backgroundColor, height: constraints.maxHeight, child: widget.child);
          },
        );
      case MultiStatusType.statusLoading:
        return _buildLoadingWidget();
      case MultiStatusType.statusEmpty:
        return _buildEmptyWidget();
      case MultiStatusType.statusError:
        return _buildErrorWidget();
    }
  }

  _buildLoadingWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(bottom: !widget.hasAppBar ? 0 : safeAreaEdgeInsets.top + kAppbarHeight.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.loadingWidget != null ? [widget.loadingWidget!] : [loadingIndicator()],
            ),
          ),
        );
      },
    );
  }

  _buildEmptyWidget() {
    List<Widget> content = widget.emptyWidget != null
        ? [widget.emptyWidget!]
        : [
            Image.asset(Assets.commonPageEmpty, width: 150.w, height: 150.w),
            SizedBox(height: 16.h),
            ..._getActions(widget.emptyActionType),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...content,
                Flexible(child: SizedBox(height: !widget.hasAppBar ? 0 : safeAreaEdgeInsets.top + kAppbarHeight.h)),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildErrorWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            color: widget.backgroundColor,
            width: Get.width,
            height: constraints.maxHeight,
            padding: EdgeInsets.only(bottom: !widget.hasAppBar ? 0 : safeAreaEdgeInsets.top + kAppbarHeight.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.errorWidget != null
                  ? [widget.errorWidget!]
                  : [
                      Image.asset(Assets.commonPageError, width: 150.w, height: 150.w),
                      SizedBox(height: 16.h),
                      CommonText.instance(
                        'Sourece loaded failed,please check your network',
                        14.sp,
                        color: CommonColors.white.withOpacity(0.5),
                        fontWeight: CommonFontWeight.semiBold,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      CommonButton(
                        minSize: 40.h,
                        borderRadius: BorderRadius.circular(20.r),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        color: CommonColors.primaryColor,
                        onPressed: widget.action,
                        child: CommonText.instance(widget.actionText ?? '', 14.sp, color: CommonColors.color060600, fontWeight: CommonFontWeight.medium),
                      ),
                    ],
            ),
          ),
        );
      },
    );
  }

  _getActions(EmptyActionType emptyActionType) {
    switch (emptyActionType) {
      case EmptyActionType.text:
        return [
          CommonText.instance(
            widget.emptyText ?? 'No video available',
            14.sp,
            color: CommonColors.white.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ];
      case EmptyActionType.button:
        return [
          CommonButton(
            minSize: 32.h,
            borderRadius: BorderRadius.circular(16.r),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            color: CommonColors.primaryColor,
            onPressed: widget.action,
            child: CommonText.instance(widget.actionText ?? '', 14.sp, color: CommonColors.white),
          ),
        ];
      default:
        return [
          CommonText.instance(
            widget.emptyText ?? 'No video available',
            14.sp,
            color: CommonColors.white.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          CommonButton(
            minSize: 32.h,
            borderRadius: BorderRadius.circular(16.r),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            color: CommonColors.primaryColor,
            onPressed: widget.action,
            child: CommonText.instance(widget.actionText ?? '', 14.sp, color: CommonColors.white),
          ),
        ];
    }
  }

  @override
  bool get wantKeepAlive => true;
}
