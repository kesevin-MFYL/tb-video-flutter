import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    handArguments(Get.arguments);
    handRegister();
  }

  @override
  void onReady() {
    super.onReady();
    fetchData();
  }

  ///处理传递数据
  void handArguments(dynamic arguments) {}

  ///初始化注册（EventBus、通知、数据流等）
  void handRegister() {}

  ///初始化数据
  void fetchData() {}

  void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
