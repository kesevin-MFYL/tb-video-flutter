import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class HistoryController extends BaseController {
  var isEdit = false.obs;

  var chooseList = <MediaItemEntity>[];

  void changeEdit() {
    if (isEdit.value) {
      chooseList.clear();
    }
    isEdit.value = !isEdit.value;
  }
}
