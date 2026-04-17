import 'package:editvideo/modules/home/controllers/my_memory_controller.dart';
import 'package:editvideo/modules/home/widget/video_cell.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyMemoryPage extends StatefulWidget {
  const MyMemoryPage({super.key});

  @override
  State<MyMemoryPage> createState() => _MyMemoryPageState();
}

class _MyMemoryPageState extends State<MyMemoryPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<MyMemoryController>(
      init: MyMemoryController(),
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
              itemCount: controller.memoryList.length,
              itemBuilder: (context, index) {
                final memoryInfo = controller.memoryList[index];
                return VideoCell(
                  memoryInfo: memoryInfo,
                  cellType: VideoCellType.memory,
                  action: (memoryInfo, cellType) {
                    Get.toNamed(Routes.editVideo, arguments: {'memoryInfo': memoryInfo});
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
