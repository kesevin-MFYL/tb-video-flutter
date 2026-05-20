import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/page_model.dart';
import 'package:editvideo/widget/bottom_sheet/delete_search_history_bottom_sheet.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:editvideo/utils/storage.dart';

class SearchController extends BaseController {
  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

  @override
  void fetchData() {
    loadSearchHistory();
  }

  void loadSearchHistory() {
    searchHistoryList.value = Storage.getSearchHistory();
  }

  /// 搜索历史
  var searchHistoryList = <String>[].obs;
  var isHistoryExpanded = false.obs;

  final textController = TextEditingController();
  final focusNode = FocusNode();

  var multiStatus = MultiStatusType.statusLoading;

  final _pageHelper = PageModel();
  var hasMore = false;

  /// 联想词集合
  var triggerWordList = <String>[];

  /// 搜索结果
  var mediaList = <MediaItemEntity>[];

  /// 显示联想词
  var showTrigger = false.obs;

  /// 显示搜索结果
  var showSearchResult = false.obs;

  Future<void> onRefresh() async {
    search(textController.text, isRefresh: true);
  }

  Future<void> onLoadMore() async {
    search(textController.text, isRefresh: false);
  }

  /// 获取联想词
  void getTriggerWords() async {
    if (showTrigger.value == false) {
      showTrigger.value = true;
    }

    final value = textController.text.trim();

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      final response = await dio.get('https://v3.sg.media-imdb.com/suggestion/x/$value.json?includeVideos=1');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['d'] is List) {
          triggerWordList.clear();
          for (var item in data['d']) {
            if (item['l'] != null) {
              triggerWordList.add(item['l'].toString());
            }
          }
          update();
        }
      }
    } catch (e) {
      commonDebugPrint("getTriggerWords: Error fetching trigger words: $e");
    }
  }

  void toSearch() {
    if (FocusManager.instance.primaryFocus?.hasFocus == true) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (textController.text.trim().isEmpty) return;

    Storage.addSearchHistory(textController.text.trim());
    loadSearchHistory();

    showSearchResult.value = true;
    multiStatus = MultiStatusType.statusLoading;
    onRefresh();
  }

  void clearSearchHistory() {
    Storage.clearSearchHistory();
    searchHistoryList.clear();
  }

  void search(String keyword, {bool isRefresh = true}) async {
    if (isRefresh) {
      _pageHelper.resetPage();
    }
    final result = await HomeApi.searchMedia(
      keyword: keyword,
      pageNum: _pageHelper.page,
      pageSize: _pageHelper.pageSize,
    );
    if (result.isSuccess) {
      final dataList = result.responseData?.data ?? [];
      if (isRefresh) {
        mediaList.clear();
      }
      mediaList.addAll(dataList);
      multiStatus = mediaList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
      hasMore = dataList.length >= _pageHelper.pageSize;
      _pageHelper.addPage();

      if (isRefresh) {
        refreshController.finishRefresh();
      } else {
        refreshController.finishLoad();
      }

      update();
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatus = MultiStatusType.statusError;
    }
  }

  void changeToHistory() {
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
    }

    showTrigger.value = false;
    showSearchResult.value = false;

    triggerWordList.clear();
    mediaList.clear();
    loadSearchHistory();
  }

  void changeToTrigger() {
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
    }
    getTriggerWords();
    showSearchResult.value = false;
  }

  void showDeleteHistoryBottomSheet() {
    unfocus();
    DeleteSearchHistoryBottomSheet.show(
      onConfirm: () {
        clearSearchHistory();
      },
    );
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
