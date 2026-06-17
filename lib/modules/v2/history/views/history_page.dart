import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/modules/v2/history/controllers/history_controller.dart';
import 'package:editvideo/modules/v2/history/history_media_cell.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
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
                    _buildHeader(),

                    Expanded(
                      child: MultiStatusView(
                        hasAppBar: false,
                        currentStatus: controller.multiStatusType,
                        emptyText: 'You haven\'t watched any videoshere yet',
                        child: Obx(() {
                          return SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: controller.isEdit.value ? 32.w : 0),
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
                    ),
                  ],
                ),
              ),
            ],
          )
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48.w,
      margin: EdgeInsets.only(top: 8.w, bottom: 16.w),
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
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.w),
      child: Row(
        children: [
          if (assets.isNotEmptyString()) ...[Image.asset(assets!, width: 24.w, height: 24.w), SizedBox(width: 8.w)],
          CommonText.instance(title, 16.sp, fontWeight: CommonFontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildItem(MediaHistoryEntity item) {
    return Obx(() {
      final isEdit = controller.isEdit.value;
      final isSelected = controller.chooseList.contains(item);

      return HistoryMediaCell(
        mediaHistoryEntity: item,
        isEdit: isEdit,
        isSelected: isSelected,
        toggleAction: (item) {
          controller.toggleItem(item);
        },
        deleteAction: (item) {
          controller.deleteItem(item);
        },
        tapAction: (item) {
          controller.toMediaDetailSinglePage(mediaId: item.id, mediaType: item.type);
        },
      );
    });
  }
}
