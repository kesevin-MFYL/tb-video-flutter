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
    multiStatusType = draftList.isEmpty
        ? MultiStatusType.statusEmpty
        : MultiStatusType.statusContent;
    update();
  }
}