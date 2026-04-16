import 'package:editvideo/config/build_config.dart';
import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/config/environment.dart';
import 'package:editvideo/config/log/logger_config.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppManager {
  static final instance = AppManager._();

  AppManager._();

  Future<void> initial() async {
    WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 配置环境
    BuildConfig.instantiate(envType: Environment.development);
    // 配置日志
    LoggerConfig.instantiate();
    // 初始化存储
    await Storage.init();
    // 配置加载框
    _configLoading();
  }

  void _configLoading() {
    EasyLoading.instance
      ..animationDuration = Duration.zero
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..textColor = CommonColors.background
      ..indicatorColor = CommonColors.background
      ..progressColor = CommonColors.background
      ..backgroundColor = CommonColors.white
      ..userInteractions = false
      ..dismissOnTap = false
      ..animationStyle = EasyLoadingAnimationStyle.scale;
  }
}
