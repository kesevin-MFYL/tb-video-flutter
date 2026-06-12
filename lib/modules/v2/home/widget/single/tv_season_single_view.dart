import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/home/controllers/multi/media_detail_multi_controller.dart';
import 'package:editvideo/modules/v2/home/controllers/single/media_detail_single_controller.dart';
import 'package:editvideo/utils/common_ui.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/tabbar/common_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TvSeasonSingleView extends StatelessWidget {
  const TvSeasonSingleView({
    super.key,
    required this.controller,
    required this.contentBuilder,
    this.isDialog = false,
    this.needAdapted = true,
  });

  final MediaDetailSingleController controller;
  final Widget Function(BuildContext context, List<dynamic> episodeList) contentBuilder;
  final bool isDialog;
  final bool needAdapted;

  @override
  Widget build(BuildContext context) {
    Widget contentWidget = Obx(() {
      return MultiStatusView(
        currentStatus: controller.episodeStatusType.value,
        emptyWidget: CommonText.instance(
          'No episodes yet',
          needAdapted ? 14.sp : 14,
          color: CommonColors.white.withOpacity(0.5),
          textAlign: TextAlign.center,
        ),
        errorWidget: CommonButton(
          minSize: isDialog ? (needAdapted ? 40.w : 40) : 30.w,
          borderRadius: BorderRadius.circular(isDialog ? (needAdapted ? 20.w : 20) : 15.w),
          padding: EdgeInsets.symmetric(horizontal: needAdapted ? 24.w : 24),
          color: CommonColors.primaryColor,
          onPressed: controller.reloadEpisodeList,
          child: CommonText.instance(
            'Try Again',
            needAdapted ? 14.sp : 14,
            color: CommonColors.color060600,
            fontWeight: CommonFontWeight.medium,
          ),
        ),
        loadingWidget: isDialog
            ? loadingIndicator(size: needAdapted ? 40.w : 40, strokeWidth: 3.5)
            : loadingIndicator(size: 30.w, strokeWidth: 2),
        hasAppBar: false,
        child: contentBuilder(context, controller.episodeList),
      );
    });

    if (isDialog) {
      contentWidget = Expanded(child: contentWidget);
    } else {
      contentWidget = SizedBox(height: 48.w, child: contentWidget);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: needAdapted ? 16.w : 16),
          child: Row(
            children: [
              if (!isDialog) ...[
                Image.asset(Assets.commonIconSelections, width: 24.w, height: 24.w),
                SizedBox(width: 12.w),
              ],

              CommonText.instance(
                'Selections',
                needAdapted ? 16.sp : 16,
                color: isDialog ? CommonColors.white.withOpacity(0.8) : CommonColors.white,
                fontWeight: CommonFontWeight.bold,
              ),
              Spacer(),

              if (!isDialog)
                CommonButton(
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  spacing: 4.w,
                  suffixDirectional: SuffixDirectional.right,
                  suffixWidget: Image.asset(Assets.commonIconVideoArrowRight, width: 16.w, height: 16.w),
                  onPressed: controller.bottomSeasonsChanged,
                  child: CommonText.instance(
                    'View ${controller.seasonList.length}',
                    12.sp,
                    color: CommonColors.primaryColor,
                    decoration: TextDecoration.underline,
                    decorationColor: CommonColors.primaryColor,
                  ),
                )
              else
                CommonButton(
                  minSize: 0,
                  borderRadius: BorderRadius.zero,
                  onPressed: () {
                    if (needAdapted) {
                      controller.bottomSeasonsChanged();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Image.asset(
                    Assets.commonIconBottomClose,
                    width: needAdapted ? 24.w : 24,
                    height: needAdapted ? 24.w : 24,
                  ),
                ),
            ],
          ),
        ),
        if (controller.seasonList.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(top: isDialog ? (needAdapted ? 24.w : 16) : 24.w, bottom: !isDialog ? 16.w : 0),
            child: CommonIndicatorTabBar(
              tabController: controller.tabController,
              tabs: controller.seasonList,
              isScrollable: true,
              needAdapted: needAdapted,
              onChanged: controller.seasonTabChanged,
            ),
          ),
          contentWidget,
        ],
      ],
    );
  }
}
