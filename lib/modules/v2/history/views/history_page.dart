import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/modules/v2/history/controllers/history_controller.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HistoryController>(
      init: HistoryController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                Expanded(
                  child: Obx(() {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: controller.isEdit.value ? controller.getBottomSheetHeight : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.todayList.isNotEmpty) ...[
                            _buildSectionTitle('Today', assets: Assets.commonIconToday),
                            ...controller.todayList.map((item) => _buildItem(item)),
                            SizedBox(height: 16.w),
                          ],
                          if (controller.yesterdayList.isNotEmpty) ...[
                            _buildSectionTitle('Yesterday'),
                            ...controller.yesterdayList.map((item) => _buildItem(item)),
                            SizedBox(height: 16.w),
                          ],
                          if (controller.earlyList.isNotEmpty) ...[
                            _buildSectionTitle('Early'),
                            ...controller.earlyList.map((item) => _buildItem(item)),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        final isEdit = controller.isEdit.value;
        return Row(
          children: [
            !isEdit
                ? Stack(
                    children: [
                      Image.asset(Assets.commonIconHistoryTitle, width: 86.w, height: 48.w),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Image.asset(Assets.commonTabSelected, width: 93.w, height: 18.w),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: controller.toggleAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          controller.isAllSelected ? Assets.commonIconSelected : Assets.commonIconUnselected,
                          width: 24.w,
                          height: 24.w,
                        ),
                        SizedBox(width: 8.w),
                        CommonText.instance('All', 16.sp, fontWeight: CommonFontWeight.medium),
                      ],
                    ),
                  ),
            Spacer(),
            GestureDetector(
              onTap: controller.changeEdit,
              child: !isEdit
                  ? Image.asset(Assets.commonIconHistoryEdit, width: 32.w, height: 32.w)
                  : CommonText.instance('Cancel', 16.sp, fontWeight: CommonFontWeight.medium),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, {String? assets}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.w),
      child: Row(
        children: [
          if (assets.isNotEmptyString()) ...[Image.asset(assets!, width: 24.w, height: 24.w), SizedBox(width: 8.w)],
          CommonText.instance(title, 16.sp, fontWeight: CommonFontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildItem(MediaItemEntity item) {
    return Obx(() {
      final isEdit = controller.isEdit.value;
      final isSelected = controller.chooseList.contains(item);

      return GestureDetector(
        onTap: () {
          if (isEdit) {
            controller.toggleItem(item);
          } else {
            // normal tap behavior (e.g. play video)
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 16.w),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isEdit)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Center(
                      child: Image.asset(
                        isSelected ? Assets.commonIconSelected : Assets.commonIconUnselected,
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CommonImageView.normal(
                    imageUrl: item.cover,
                    alignment: Alignment.topCenter,
                    width: 120.w,
                    height: 68.w,
                    errorWidget: (context, url, error) {
                      return Center(
                        child: Image.asset(Assets.commonMediaPlaceholder, width: 40.w, height: 40.w, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.instance(
                        item.title ?? '',
                        14.sp,
                        fontWeight: CommonFontWeight.medium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 20.w,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color: CommonColors.color84705C.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CommonText.instance(
                                  '1h 17m remaining',
                                  10.sp,
                                  color: CommonColors.white.withOpacity(0.8),
                                  fontWeight: CommonFontWeight.medium,
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          CommonText.instance(
                            '90%',
                            12.sp,
                            color: CommonColors.primaryColor.withOpacity(0.5),
                            fontWeight: CommonFontWeight.medium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
