import 'dart:async';

import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:get/get.dart';

class HistoryController extends BaseController {
  var isEdit = false.obs;

  var chooseList = <MediaHistoryEntity>[].obs;

  var todayList = <MediaHistoryEntity>[].obs;
  var yesterdayList = <MediaHistoryEntity>[].obs;
  var earlyList = <MediaHistoryEntity>[].obs;

  late StreamSubscription<EventBusModel> _historyRefreshSubscription;

  void changeEdit() {
    if (isEdit.value) {
      chooseList.clear();
    }
    isEdit.value = !isEdit.value;
    EventBusManager.instance.post(EventBusName.historyEdit, value: isEdit.value);
  }

  @override
  void handRegister() {
    _historyRefreshSubscription = EventBusManager.instance.addObserver(EventBusName.historyRefresh, (value) async {
      loadHistory();
    });
  }

  @override
  void fetchData() {
    loadHistory();
  }

  void loadHistory() {
    final list = Storage.getViewedMedia();
    todayList.clear();
    yesterdayList.clear();
    earlyList.clear();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in list) {
      if (item.viewTime != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(item.viewTime!);
        final day = DateTime(date.year, date.month, date.day);

        if (day == today) {
          todayList.add(item);
        } else if (day == yesterday) {
          yesterdayList.add(item);
        } else {
          earlyList.add(item);
        }
      }
    }
  }

  void toggleItem(MediaHistoryEntity item) {
    if (chooseList.contains(item)) {
      chooseList.remove(item);
    } else {
      chooseList.add(item);
    }
  }

  void toggleAll() {
    if (isAllSelected) {
      chooseList.clear();
    } else {
      chooseList.clear();
      chooseList.addAll(todayList);
      chooseList.addAll(yesterdayList);
      chooseList.addAll(earlyList);
    }
  }

  bool get isAllSelected {
    final totalCount = todayList.length + yesterdayList.length + earlyList.length;
    return totalCount > 0 && chooseList.length == totalCount;
  }

  void deleteSelected() async {
    await Storage.deleteViewedMedia(chooseList.toList());
    chooseList.clear();
    loadHistory();
  }

  ///todo 跳转播放页面
  void toMediaDetail(MediaItemEntity mediaItemEntity) {
    Get.toNamed(Routes.mediaDetailPage, arguments: mediaItemEntity);
  }

  @override
  void onClose() {
    _historyRefreshSubscription.cancel();
    super.onClose();
  }
}
