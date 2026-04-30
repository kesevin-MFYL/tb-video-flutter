import 'dart:async';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LaunchController extends GetxController {
  bool _hasNavigatedToMain = false;
  Timer? _timeoutTimer;
  Timer? _checkAdTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeAppAndAds();
  }

  Future<void> _initializeAppAndAds() async {
    // 1. 初始化 RemoteConfig 设置
    await RemoteConfigManager().initialize();

    // 2. 设置 7 秒超时器，如果 7 秒后仍未处理完毕，直接跳转 main
    _timeoutTimer = Timer(const Duration(seconds: 7), () {
      debugPrint('LaunchController: 7 seconds timeout reached. Navigating to main.');
      _navigateToMain();
    });

    // 3. 拉取远端配置
    bool fetchSuccess = await RemoteConfigManager().fetchAndActivateConfig();

    // 如果拉取失败或者配置为空，直接跳转 main
    if (!fetchSuccess || RemoteConfigManager().config == null) {
      debugPrint('LaunchController: Failed to fetch config or config is null. Navigating to main.');
      _navigateToMain();
      return;
    }

    final config = RemoteConfigManager().config!;
    
    // 4. 根据配置分别加载 open 和 behavior 场景的广告
    AdManager.instance.loadAd('open', config.open);
    AdManager.instance.loadAd('behavior', config.behavior);
    AdManager.instance.loadAd('NVhome', config.behavior);

    // 5. 等待一小段时间让广告有机会加载完成（比如给 AdMob 请求一点时间）
    // 这里我们等待最多剩余的超时时间（因为已经设置了 7 秒强跳定时器）
    // 但为了确保我们能尝试展示，我们使用循环检查或者延迟一点时间后展示
    _tryShowOpenAd();
  }

  void _tryShowOpenAd() {
    // 循环检查 open 场景广告是否准备就绪，每隔 500 毫秒检查一次，直到超时
    _checkAdTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_hasNavigatedToMain) {
        timer.cancel();
        return;
      }

      if (AdManager.instance.isAdAvailable('open')) {
        // 取消超时定时器和检查定时器，因为我们要开始展示广告了
        _timeoutTimer?.cancel();
        timer.cancel();

        debugPrint('LaunchController: Open ad is ready. Showing ad.');
        AdManager.instance.showAdIfAvailable('open', onAdDismissed: () {
          debugPrint('LaunchController: Open ad dismissed. Navigating to main.');
          // 在原生全屏广告关闭时，给 Flutter 渲染一点恢复的缓冲时间（比如 100 毫秒）
          // 否则可能会因为原生转场动画和 GetX 路由切换同时发生而导致界面僵死或延迟
          // Future.delayed(const Duration(milliseconds: 100), () {
            _navigateToMain();
          // });
        });
      }
    });
  }

  void _navigateToMain() {
    if (_hasNavigatedToMain) return;
    _hasNavigatedToMain = true;
    _timeoutTimer?.cancel();
    _checkAdTimer?.cancel();
    Get.offAllNamed(Routes.main);
  }

  @override
  void onClose() {
    _timeoutTimer?.cancel();
    _checkAdTimer?.cancel();
    super.onClose();
  }
}
