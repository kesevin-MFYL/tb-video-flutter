import 'dart:async';

import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/admob/app_lifecycle_reactor.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/modules/v1/setting/views/setting_page.dart';
import 'package:editvideo/modules/v2/explore/views/explore_page.dart';
import 'package:editvideo/modules/v2/history/controllers/history_controller.dart';
import 'package:editvideo/modules/v2/history/views/history_page.dart';
import 'package:editvideo/modules/v2/home/views/home_b_page.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainBController extends BaseController {
  var currentIndex = 0;

  final tabBarPages = [const HomeBPage(), const ExplorePage(), const HistoryPage(), const SettingPage()];

  late StreamSubscription<EventBusModel> _historyEditSubscription;

  var chooseList = <MediaHistoryEntity>[].obs;
  var showDeletePopup = false.obs;

  @override
  void handRegister() async {
    AppLifecycleReactor.instance.listenToAppStateChanges();

    _historyEditSubscription = EventBusManager.instance.addObserver(EventBusName.historyEdit, (value) async {
      if (value is bool) {
        showDeletePopup.value = value;
      }
    });
  }

  void tabChanged(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      update();
    }
  }

  double get getDeletePopupHeight =>
      'Text'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.bold)).height + 40.w + 32.w;

  void deleteHistory() {
    if (Get.isRegistered<HistoryController>()) {
      final historyController = Get.find<HistoryController>();
      historyController.deleteSelected();
    }
  }

  @override
  void onClose() {
    _historyEditSubscription.cancel();
    super.onClose();
  }
}
