import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class HomeBController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: false);

  var homeSectionList = <HomeSectionEntity>[];
  var topPicksList = <MediaItemEntity>[];

  @override
  void fetchData() async {
    getDataFromServer();
  }

  void getDataFromServer() async {
    Future.wait([_getHomeSection(), getTopPicks()]).then((list) {
      update();
    });
  }

  Future<void> _getHomeSection() async {
    final result = await HomeApi.getHomeSection();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      homeSectionList = listData ?? [];
      multiStatusType = homeSectionList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
      refreshController.finishRefresh();
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
  }

  Future<void> getTopPicks({bool needUpdate = false}) async {
    final result = await HomeApi.getTopPicks();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      topPicksList = listData ?? [];
      if (needUpdate) {
        update();
      }
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  void viewAll(SectionType sectionType, HomeSectionEntity? section) {
    if (sectionType == SectionType.mediaList) {
      // 单片，进入单片二级页查看所有
      Get.toNamed(Routes.mediaListSubPage, arguments: section);
    } else if (sectionType == SectionType.imdbInterest) {
      // 分类，进入分类二级页查看所有
      Get.toNamed(Routes.interestAllPage);
    }
  }

  void mediaTap(MediaItemEntity mediaItem, SectionType sectionType) {
    if (sectionType == SectionType.mediaList) {
      // 单片，进入视频播放页
      toMediaDetail(mediaItem);
    } else if (sectionType == SectionType.imdbList) {
      // 合集，进入合集二级页
      Get.toNamed(Routes.imdbListSubPage, arguments: mediaItem);
    } else if (sectionType == SectionType.imdbInterest) {
      // 进入分类详情页
      Get.toNamed(Routes.interestDetailPage, arguments: mediaItem);
    } else if (sectionType == SectionType.streamingMedia) {
      // 渠道，进入视频播放页
      toMediaDetail(mediaItem);
    }
  }

  ///跳转搜索
  void toSearch() {
    Get.toNamed(Routes.searchPage);
  }

  ///todo 跳转播放页面
  void toMediaDetail(MediaItemEntity mediaItemEntity) {
    Get.toNamed(Routes.mediaDetailPage, arguments: mediaItemEntity);
  }
}
