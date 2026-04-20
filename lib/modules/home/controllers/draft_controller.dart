import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';

class DraftController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  /// draft列表
  var draftList = <MemoryInfo>[];

  @override
  void onInit() {
    super.onInit();
    getDataFromLocal();
  }

  void getDataFromLocal() async {
    draftList = Storage.getDraftMemories();
    draftList.sort((a, b) => (b.operationTime ?? 0).compareTo(a.operationTime ?? 0));
    multiStatusType = draftList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    update();
  }

  void deleteDraft(MemoryInfo memoryInfo) async {
    await Storage.deleteDraftMemory(memoryInfo.id ?? '');
    getDataFromLocal();
  }
}
