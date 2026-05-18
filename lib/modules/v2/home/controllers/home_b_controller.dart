import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class HomeBController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  final refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  var homeSectionList = <HomeSectionEntity>[];
  var topPicksList = <MediaItemEntity>[];

  @override
  void fetchData() async {
    Future.wait([_getHomeSection(), _getTopPicks()]).then((list) {
      update();
    });
  }

  Future<void> _getHomeSection() async {
    final result = await HomeApi.getHomeSection();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      homeSectionList = listData ?? [];
      multiStatusType = homeSectionList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
  }

  Future<void> _getTopPicks() async {
    final result = await HomeApi.getTopPicks();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      topPicksList = listData ?? [];
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  void viewAll(SectionType sectionType, HomeSectionEntity? section) {
    if (sectionType == SectionType.mediaList) {// 单片，进入单片二级页查看所有
      EasyLoading.showToast('单片，进入单片二级页查看所有');
    } else if (sectionType == SectionType.imdbInterest) {// 分类，进入分类二级页查看所有
      EasyLoading.showToast('分类，进入分类二级页查看所有');
    }
  }

  void mediaTap(SectionType sectionType, MediaItemEntity mediaItem) {
    if (sectionType == SectionType.mediaList) {// 单片，进入视频播放页
      EasyLoading.showToast('单片，进入视频播放页');
    } else if (sectionType == SectionType.imdbList) {// 合集，进入合集二级页
      EasyLoading.showToast('合集，进入合集二级页');

    } else if (sectionType == SectionType.imdbInterest) {// 分类，进入分类详情页
      EasyLoading.showToast('分类，进入分类详情页');

    } else if (sectionType == SectionType.streamingMedia) {// 渠道，进入视频播放页
      EasyLoading.showToast('渠道，进入视频播放页');

    }
  }

  void toSearch() {

  }
}