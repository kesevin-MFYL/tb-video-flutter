import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/page_model.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum MediaFilterType { mediaType, genres, year, country }

class ExploreController extends BaseController {
  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  final scrollController = ScrollController();

  var multiStatus = MultiStatusType.statusLoading;

  final _pageModel = PageModel();
  var hasMore = false;

  /// 搜索结果
  var mediaList = <MediaItemEntity>[];

  var typeFilter = <String>['All', 'Movies', 'Tv shows'];
  var genresFilter = <String>[];
  var yearFilter = <String>[];
  var countryFilter = <String>[];

  var typeFilterSelectedIndex = 0.obs;
  var genresFilterSelectedIndex = 0.obs;
  var yearFilterSelectedIndex = 0.obs;
  var countryFilterSelectedIndex = 0.obs;

  var showFilterTotal = false.obs;

  List<String> get selectedFilterNames {
    List<String> names = [];
    if (typeFilter.isNotEmpty && typeFilterSelectedIndex.value < typeFilter.length) {
      names.add(typeFilter[typeFilterSelectedIndex.value]);
    }
    if (genresFilter.isNotEmpty && genresFilterSelectedIndex.value < genresFilter.length) {
      names.add(genresFilter[genresFilterSelectedIndex.value]);
    }
    if (yearFilter.isNotEmpty && yearFilterSelectedIndex.value < yearFilter.length) {
      names.add(yearFilter[yearFilterSelectedIndex.value]);
    }
    if (countryFilter.isNotEmpty && countryFilterSelectedIndex.value < countryFilter.length) {
      names.add(countryFilter[countryFilterSelectedIndex.value]);
    }
    return names;
  }

  var popShowing = false.obs;

  Future<void> onRefresh({bool showLoading = false}) async {
    if (showLoading) {
      multiStatus = MultiStatusType.statusLoading;
      update();
    }
    _search(isRefresh: true);
  }

  Future<void> onLoadMore() async {
    _search(isRefresh: false);
  }

  @override
  void handRegister() {
    _pageModel.pageSize = 27;

    scrollController.addListener(() {
      var totalScrollRange = scrollController.position.maxScrollExtent;
      var offset = scrollController.offset;
      showFilterTotal.value = (offset / totalScrollRange).clamp(0.0, 1.0) == 1.0;
    });
  }

  @override
  void fetchData() {
    getDataFromServer();
  }

  void getDataFromServer() async {
    Future.wait([_getMediaFilter(), _search(needUpdate: false)]).then((list) {
      update();
    });
  }

  Future<void> _getMediaFilter() async {
    final result = await HomeApi.getMediaFilter();
    if (result.isSuccess) {
      final mediaFilterEntity = result.responseData?.data;
      genresFilter = ['All Genres'];
      if (mediaFilterEntity?.genreList != null) {
        genresFilter.addAll(mediaFilterEntity!.genreList!);
      }
      yearFilter = ['All Release Years'];
      if (mediaFilterEntity?.yearList != null) {
        yearFilter.addAll(mediaFilterEntity!.yearList!);
      }
      countryFilter = ['All Countries'];
      if (mediaFilterEntity?.countryCodeList != null) {
        countryFilter.addAll(mediaFilterEntity!.countryCodeList!);
      }
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
    }
  }

  Future<void> _search({bool isRefresh = true, bool needUpdate = true}) async {
    if (isRefresh) {
      _pageModel.resetPage();
    }

    int? type;
    if (typeFilterSelectedIndex.value == 1) {
      type = 1;
    } else if (typeFilterSelectedIndex.value == 2) {
      type = 2;
    }

    String? genre;
    if (genresFilterSelectedIndex > 0 && genresFilterSelectedIndex < genresFilter.length) {
      genre = genresFilter[genresFilterSelectedIndex.value];
    }

    String? year;
    if (yearFilterSelectedIndex > 0 && yearFilterSelectedIndex < yearFilter.length) {
      year = yearFilter[yearFilterSelectedIndex.value];
    }

    String? countryCode;
    if (countryFilterSelectedIndex > 0 && countryFilterSelectedIndex < countryFilter.length) {
      countryCode = countryFilter[countryFilterSelectedIndex.value];
    }

    final result = await HomeApi.searchMedia(
      type: type,
      genre: genre,
      year: year,
      countryCode: countryCode,
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
        refreshController.finishLoad(hasMore ? IndicatorResult.success : IndicatorResult.noMore);
      }

      if (needUpdate) {
        update();
      }
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatus = MultiStatusType.statusError;
      update();
    }
  }

  void changeFilter(int index, MediaFilterType mediaFilterType) {
    switch (mediaFilterType) {
      case MediaFilterType.mediaType:
        if (typeFilterSelectedIndex.value == index) return;
        typeFilterSelectedIndex.value = index;
      case MediaFilterType.genres:
        if (genresFilterSelectedIndex.value == index) return;
        genresFilterSelectedIndex.value = index;
      case MediaFilterType.year:
        if (yearFilterSelectedIndex.value == index) return;
        yearFilterSelectedIndex.value = index;
      case MediaFilterType.country:
        if (countryFilterSelectedIndex.value == index) return;
        countryFilterSelectedIndex.value = index;
      default:
        return;
    }
    onRefresh(showLoading: true);
  }

  int getSelectedIndex(MediaFilterType mediaFilterType) {
    switch (mediaFilterType) {
      case MediaFilterType.mediaType:
        return typeFilterSelectedIndex.value;
      case MediaFilterType.genres:
        return genresFilterSelectedIndex.value;
      case MediaFilterType.year:
        return yearFilterSelectedIndex.value;
      case MediaFilterType.country:
        return countryFilterSelectedIndex.value;
      default:
        return -1;
    }
  }

  ///跳转搜索
  void toSearch() {
    Get.toNamed(Routes.searchPage);
  }

  //todo 跳转播放页面
  void toMediaDetail(MediaItemEntity mediaItemEntity) {
    Get.toNamed(Routes.mediaDetailPage, arguments: mediaItemEntity);
  }
}
