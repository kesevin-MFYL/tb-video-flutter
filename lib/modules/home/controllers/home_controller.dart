import 'package:editvideo/base/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum QueryType {
  myMemory,
  draft,
}

class HomeController extends BaseController {
  var queryType = QueryType.myMemory.obs;

  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
  }

  void queryChanged(QueryType type) {
    queryType.value = type;

    ///滑动页面到指定位置
    pageController.jumpToPage(queryType.value == QueryType.myMemory ? 0 : 1);
  }
}