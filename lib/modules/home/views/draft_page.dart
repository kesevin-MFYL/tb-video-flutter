import 'package:editvideo/modules/home/controllers/draft_controller.dart';
import 'package:editvideo/modules/home/widget/video_cell.dart';
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
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.w,
                childAspectRatio: 164 / 150,
              ),
              itemCount: controller.draftList.length,
              itemBuilder: (context, index) {
                final videoInfo = controller.draftList[index];
                return VideoCell(
                  videoInfo: videoInfo,
                  cellType: VideoCellType.draft,
                  action: (videoInfo, cellType) {

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
