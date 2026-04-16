import 'package:editvideo/modules/main/views/edit_video_page.dart';
import 'package:editvideo/modules/main/views/main_page.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static final routes = [
    ...MainPages.routes,
    // ...SettingPages.routes,
    ...CommonPages.routes,
  ];
}

/// 根页面
class MainPages {
  MainPages._();

  /// 路由管理
  static final routes = [
    /// main
    GetPage(
      name: Routes.main,
      page: () => MainPage(),
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
    GetPage(
      name: Routes.editVideo,
      page: () => EditVideoPage(),
    ),
  ];
}