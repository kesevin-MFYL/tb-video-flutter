import 'package:editvideo/modules/home/controllers/draft_controller.dart';
import 'package:editvideo/modules/home/widget/video_cell.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<DraftController>(
      init: DraftController(),
      builder: (controller) {
        return CommonRefresh.instance(
          hasBefore: false,
          hasMore: false,
          child: MultiStatusView(
            hasAppBar: false,
            currentStatus: controller.multiStatusType,
            child: GridView.builder(
              padding: EdgeInsets.only(left: 8.w, top: 12.h, right: 8.w, bottom: 50.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.w,
                childAspectRatio: 164 / 150,
              ),
              itemCount: controller.draftList.length,
              itemBuilder: (context, index) {
                final memoryInfo = controller.draftList[index];
                return VideoCell(
                  memoryInfo: memoryInfo,
                  cellType: VideoCellType.draft,
                  videoAction: (memoryInfo, cellType) {
                    Get.toNamed(Routes.editVideo, arguments: {'memoryInfo': memoryInfo, 'isFromDraft': true});
                  },
                  operationAction: (memoryInfo, cellType) {
                    controller.deleteDraft(memoryInfo);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
