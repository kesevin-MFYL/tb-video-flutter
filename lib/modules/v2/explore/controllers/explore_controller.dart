import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/page_model.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class ExploreController extends BaseController {
  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  var multiStatus = MultiStatusType.statusLoading;

  final _pageModel = PageModel();
  var hasMore = false;

  /// 搜索结果
  var mediaList = <MediaItemEntity>[];

  var typeFFilter = <String>[];
  var genresFilter = <String>[];
  var yearFilter = <String>[];
  var countryFilter = <String>[];

  Future<void> onRefresh() async {
    _search(isRefresh: true);
  }

  Future<void> onLoadMore() async {
    _search(isRefresh: false);
  }

  @override
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() async {
    Future.wait([_getMediaFilter(), _search()]).then((list) {
      update();
    });
  }

  Future<void> _getMediaFilter() async {
    final result = await HomeApi.getMediaFilter();
    if (result.isSuccess) {
      final mediaFilterEntity = result.responseData?.data;
      genresFilter = mediaFilterEntity?.genreList ?? [];
      yearFilter = mediaFilterEntity?.yearList ?? [];
      countryFilter = mediaFilterEntity?.countryCodeList ?? [];
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  Future<void> _search({bool isRefresh = true}) async {
    if (isRefresh) {
      _pageModel.resetPage();
    }
    final result = await HomeApi.searchMedia(
      type: 1,
      genre: '',
      year: '',
      countryCode: '',
      pageNum: _pageModel.page,
      pageSize: _pageModel.pageSize,
    );
    if (result.isSuccess) {
      final dataList = result.responseData?.data ?? [];
      if (isRefresh) {
        mediaList.clear();
      }
      mediaList.addAll(dataList);
      multiStatus = mediaList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
      hasMore = dataList.length >= _pageModel.pageSize;
      _pageModel.addPage();

      if (isRefresh) {
        refreshController.finishRefresh();
      } else {
        refreshController.finishLoad();
      }

      // update();
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatus = MultiStatusType.statusError;
    }
  }

  ///跳转搜索
  void toSearch() {
    Get.toNamed(Routes.searchPage);
  }

  void toMediaPlayPage(MediaItemEntity mediaItemEntity) {}
}
