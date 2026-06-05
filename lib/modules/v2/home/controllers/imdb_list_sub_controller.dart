import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class ImdbListSubController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: false);

  var hasRefresh = true;

  late MediaItemEntity mediaItemEntity;

  var imdbSubList = <MediaItemEntity>[];

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is MediaItemEntity) {
      mediaItemEntity = arguments;
    }
  }

  @override
  void fetchData() async {
    getImdbListSubDetail();
  }

  void getImdbListSubDetail() async {
    final result = await HomeApi.getImdbListSubDetail(id: mediaItemEntity.id);
    if (result.isSuccess) {
      hasRefresh = true;
      final subEntity = result.responseData?.data;
      imdbSubList = subEntity?.dataList ?? [];
      multiStatusType = imdbSubList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
      refreshController.finishRefresh();
    } else {
      hasRefresh = false;
      refreshController.finishRefresh();
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
    update();
  }

  void toMediaDetail(MediaItemEntity mediaItemEntity) {
    Get.toNamed(Routes.mediaDetailPage, arguments: {'mediaId': mediaItemEntity.id, 'mediaType': mediaItemEntity.type});
  }

  ///跳转搜索
  void toSearch() {
    Get.toNamed(Routes.searchPage);
  }

}
