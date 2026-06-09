import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:editvideo/modules/v2/main/controllers/main_b_controller.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class HomeBController extends BaseController {
  MainBController get mainBController => Get.find<MainBController>();

  var multiStatusType = MultiStatusType.statusLoading;

  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: false);

  var hasRefresh = true;

  var homeSectionList = <HomeSectionEntity>[];
  var topPicksList = <MediaItemEntity>[];
  var continueWatchingList = <MediaHistoryEntity>[];

  @override
  void fetchData() async {
    getDataFromServer();
  }

  void getDataFromServer() async {
    Future.wait([_getHomeSection(), getTopPicks(), _getContinueWatching()]).then((list) {
      update();
    });
  }

  /// 获取观看记录
  Future<void> _getContinueWatching({bool needUpdate = false}) async {
    final list = Storage.getViewedMedia();
    list.sort((a, b) => (b.viewTime ?? 0).compareTo(a.viewTime ?? 0));
    continueWatchingList = list.take(10).toList();
    if (needUpdate) {
      update();
    }
  }

  Future<void> _getHomeSection() async {
    final result = await HomeApi.getHomeSection();
    if (result.isSuccess) {
      hasRefresh = true;
      final listData = result.responseData?.data;
      homeSectionList = listData ?? [];
      multiStatusType = homeSectionList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
      refreshController.finishRefresh();
    } else {
      hasRefresh = false;
      refreshController.finishRefresh();
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
  }

  Future<void> getTopPicks({bool needUpdate = false}) async {
    final hasPlayVideo = Storage.getHasPlayVideo() ?? false;
    if (!hasPlayVideo) return;

    final result = await HomeApi.getTopPicks();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      topPicksList = listData ?? [];
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
    if (needUpdate) {
      update();
    }
  }

  void visibleFraction() {
    _getContinueWatching(needUpdate: true);
    getTopPicks(needUpdate: true);
  }

  void viewAllWithContinueWatching() {
    mainBController.tabChanged(2);
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
    if (sectionType == SectionType.mediaList || sectionType == SectionType.topPicks) {
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

  void toMediaDetail(MediaItemEntity mediaItemEntity) {
    Get.toNamed(Routes.mediaDetailPage, arguments: {'mediaId': mediaItemEntity.id, 'mediaType': mediaItemEntity.type});
  }
}
