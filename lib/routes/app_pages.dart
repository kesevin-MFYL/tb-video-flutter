import 'package:editvideo/modules/common/page/app_web_page.dart';
import 'package:editvideo/modules/launch/views/launch_page.dart';
import 'package:editvideo/modules/main/views/edit_video_page.dart';
import 'package:editvideo/modules/main/views/main_a_page.dart';
import 'package:editvideo/modules/main/views/main_b_page.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static final routes = [
    ...LaunchPages.routes,
    ...MainPages.routes,
    // ...SettingPages.routes,
    ...CommonPages.routes,
  ];
}

class LaunchPages {
  LaunchPages._();

  /// 路由管理
  static final routes = [
    GetPage(
      name: Routes.launch,
      page: () => LaunchPage(),
    ),
  ];
}

/// 根页面
class MainPages {
  MainPages._();

  /// 路由管理
  static final routes = [
    /// main
    GetPage(
      name: Routes.mainA,
      page: () => MainAPage(),
    ),
    GetPage(
      name: Routes.mainB,
      page: () => MainBPage(),
    ),
  ];
}

/// 设置相关页面
class SettingPages {
  SettingPages._();

  /// 路由管理
  static final routes = [
  ];
}

/// 通用页面
class CommonPages {
  CommonPages._();

  static final routes = [
    GetPage(name: Routes.webPage, page: () => const WebPage()),

    GetPage(
      name: Routes.editVideo,
      page: () => EditVideoPage(),
    ),
  ];
}