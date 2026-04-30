import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/bottom_sheet/operation_bottom_sheet_view.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class MyMemoryController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  /// memory列表
  var memoryList = <MemoryInfo>[];

  @override
  void onInit() {
    super.onInit();
    getDataFromLocal();
  }

  void getDataFromLocal() async {
    memoryList = Storage.getSavedMemories();
    memoryList.sort((a, b) => (b.operationTime ?? 0).compareTo(a.operationTime ?? 0));
    multiStatusType = memoryList.isEmpty
        ? MultiStatusType.statusEmpty
        : MultiStatusType.statusContent;
    update();
  }

  void showOperation(MemoryInfo memoryInfo) {
    OperationBottomSheetView.show(
      editAction: () {
        AdManager.instance.showAdIfAvailable('behavior', onAdDismissed: () {
          Get.toNamed(Routes.editVideo, arguments: {'memoryInfo': memoryInfo});
        });
      },
      deleteAction: () async {
        await Storage.deleteSavedMemory(memoryInfo.id ?? '');
        getDataFromLocal();
      },
    );
  }
}