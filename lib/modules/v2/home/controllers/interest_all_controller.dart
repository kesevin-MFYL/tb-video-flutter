import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/interest_all_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class InterestAllController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: false);

  var interestAllList = <InterestAllEntity>[];

  @override
  void fetchData() async {
    getInterestAllList();
  }

  void getInterestAllList() async {
    final result = await HomeApi.getAllInterest();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      interestAllList = listData ?? [];
      multiStatusType = interestAllList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
      refreshController.finishRefresh();
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
    update();
  }

  void viewAll(InterestAllEntity interestAllEntity) {
    Get.toNamed(Routes.interestSubPage, arguments: interestAllEntity);
  }

  void toInterestDetail(MediaItemEntity mediaItemEntity, SectionType sectionType) {
  }
}
