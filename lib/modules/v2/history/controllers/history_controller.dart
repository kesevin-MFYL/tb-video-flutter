import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HistoryController extends BaseController {
  var isEdit = false.obs;

  var chooseList = <MediaItemEntity>[].obs;

  var todayList = <MediaItemEntity>[].obs;
  var yesterdayList = <MediaItemEntity>[].obs;
  var earlyList = <MediaItemEntity>[].obs;

  double get getBottomSheetHeight => safeAreaBottomDistance(
    'Text'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.bold)).height + 40.w + 32.w,
  );

  void changeEdit() {
    if (isEdit.value) {
      chooseList.clear();
    }
    isEdit.value = !isEdit.value;
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

  void toggleItem(MediaItemEntity item) {
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
}
