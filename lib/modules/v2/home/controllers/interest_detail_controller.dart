import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/mixin/media_operate_mixin.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/interest_detail_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InterestDetailController extends BaseController with MediaOperateMixin {
  var multiStatusType = MultiStatusType.statusLoading;

  final scrollController = ScrollController();
  var opacity = 0.0.obs;

  late MediaItemEntity mediaItemEntity;

  InterestDetailEntity? interestDetailEntity;

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is MediaItemEntity) {
      mediaItemEntity = arguments;
    }
  }

  @override
  void handRegister() {
    /// 滚动监听
    scrollController.addListener(() {
      var offset = scrollController.offset;
      //titleView的变化
      opacity.value = (offset / 90).clamp(0.0, 1.0);
    });
  }

  @override
  void fetchData() async {
    getInterestDetail();
  }

  void getInterestDetail() async {
    final result = await HomeApi.getInterestDetail(id: mediaItemEntity.id);
    if (result.isSuccess) {
      interestDetailEntity = result.responseData?.data;
      multiStatusType = MultiStatusType.statusContent;
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
    update();
  }

  void viewAll(HomeSectionEntity section) {
    // 单片，进入单片二级页查看所有
    Get.toNamed(Routes.mediaListSubPage, arguments: section);
  }
}
