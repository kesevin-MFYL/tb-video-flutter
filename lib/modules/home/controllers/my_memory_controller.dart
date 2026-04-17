import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';

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
}