import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/home/controllers/imdb_list_sub_controller.dart';
import 'package:editvideo/modules/v2/home/widget/imdb_list_sub_cell.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 合集二级页面
class ImdbListSubPage extends GetView<ImdbListSubController> {
  const ImdbListSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImdbListSubController>(
      init: ImdbListSubController(),
      builder: (controller) {
        return PageBase(
          isTransparentAppBar: true,
          title: controller.mediaItemEntity.title,
          actions: _actionView(),
          child: Stack(
            children: [
              Container(
                height: 96.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonIconSubTitleBg)),
                ),
              ),
              SafeArea(
                child: CommonRefresh.instance(
                  controller: controller.refreshController,
                  onRefresh: controller.getImdbListSubDetail,
                  hasBefore: controller.hasRefresh,
                  hasMore: false,
                  child: MultiStatusView(
                    currentStatus: controller.multiStatusType,
                    action: () {
                      controller.multiStatusType = MultiStatusType.statusLoading;
                      controller.update();
                      controller.getImdbListSubDetail();
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(height: 16.w, color: Colors.transparent),
                      itemCount: controller.imdbSubList.length,
                      itemBuilder: (context, index) {
                        final item = controller.imdbSubList[index];
                        return ImdbListSubCell(
                          mediaItem: item,
                          action: (mediaItem) => controller.toMediaDetail(mediaItem),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _actionView() {
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      onPressed: controller.toSearch,
      child: Image.asset(Assets.commonIconSubSearch, width: 24.w, height: 24.w),
    );
  }
}
