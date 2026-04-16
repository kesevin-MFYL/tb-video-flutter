import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';

class DraftController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  /// draft列表
  var draftList = <String>[];

  @override
  void onInit() {
    super.onInit();
    _getDataFromLocal();
  }

  void _getDataFromLocal() async {
    Future.delayed(Duration(seconds: 3), () {
      for (int i = 0; i < 11; i++) {
        draftList.add('draft_$i');
      }
      multiStatusType = MultiStatusType.statusContent;
      update();
    });

  }
}