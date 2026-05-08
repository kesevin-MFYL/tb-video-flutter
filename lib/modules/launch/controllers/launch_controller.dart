import 'dart:async';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/consent_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LaunchController extends GetxController {
  var _isMobileAdsInitializeCalled = false;
  var _hasNavigatedToMain = false;
  Timer? _checkAdTimer;
  Timer? _progressTimer;

  // 进度条的进度值 (0.0 到 1.0)
  double progress = 0.0;
  // 进度条的总时长 (7秒)
  final int maxDurationMs = 7000;
  // 进度条的更新间隔 (1秒)
  final int updateIntervalMs = 1000;
  int _elapsedMs = 0;

  @override
  void onInit() {
    super.onInit();
    _startProgressTimer();
    _initializeAppAndAds();
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(Duration(milliseconds: updateIntervalMs), (timer) {
      if (_hasNavigatedToMain) {
        timer.cancel();
        return;
      }
      _elapsedMs += updateIntervalMs;
      // 正常随时间增长的进度
      progress = _elapsedMs / maxDurationMs;
      if (progress >= 1.0) {
        progress = 1.0;
        timer.cancel();
        commonDebugPrint('测试日志：7秒超时，跳转主页', needSplit: false);
        // 进度条满（即7秒超时），强行跳转主页
        commonDebugPrint('LaunchController: 7 seconds timeout reached. Navigating to main.');
        _navigateToMain();
      } else {
        update();
      }
    });
  }

  Future<void> _initializeAppAndAds() async {
    // 1. 初始化 RemoteConfig 设置
    await RemoteConfigManager().initialize();

    // 3. 拉取远端配置
    RemoteConfigManager().fetchAndActivateConfig();

    // // 4. 收集隐私合规 (UMP) 并初始化 MobileAds
    //todo GDPR权限检查
    // ConsentManager.instance.gatherConsent((formError) async {
    //   if (formError != null) {
    //     commonDebugPrint('LaunchController: gatherConsent error: ${formError.message}');
    //   }
    //
    //   _initializeMobileAdsSDK();
    // });

    _initializeMobileAdsSDK();
  }

  void _initializeMobileAdsSDK() async {
    if (_isMobileAdsInitializeCalled) {
      return;
    }

    // 检查用户是否同意了广告请求
    //todo GDPR权限检查
    // bool canRequestAds = await ConsentManager.instance.canRequestAds();
    // commonDebugPrint('LaunchController: canRequestAds--$canRequestAds}');
    // if (canRequestAds) {
      commonDebugPrint('测试日志：获取到广告授权 开始拉取广告', needSplit: false);
      _isMobileAdsInitializeCalled = true;

      // 初始化 AdMob SDK
      MobileAds.instance.initialize();

      // 5. 根据配置分别加载各个场景的广告
      final config = RemoteConfigManager().config!;
      AdManager.instance.loadAd('open', config.open);
      AdManager.instance.loadAd('behavior', config.behavior);
      AdManager.instance.loadAd('NVhome', config.nvhome);

      // 6. 尝试轮询展示 open 广告
      _tryShowOpenAd();
    // }
  }

  void _tryShowOpenAd() {
    // 循环检查 open 场景广告是否准备就绪，每隔 500 毫秒检查一次，直到超时
    _checkAdTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_hasNavigatedToMain) {
        timer.cancel();
        return;
      }

      if (AdManager.instance.isAdAvailable('open')) {
        // 取消检查定时器，因为我们要开始展示广告了
        timer.cancel();
        _progressTimer?.cancel();
        
        // 发现广告时，瞬间将进度条填满
        progress = 1.0;
        update();

        commonDebugPrint('LaunchController: Open ad is ready. Showing ad.');
        AdManager.instance.showAdIfAvailable('open', onAdDismissed: () {
          commonDebugPrint('LaunchController: Open ad dismissed. Navigating to main.');
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
    _checkAdTimer?.cancel();
    _progressTimer?.cancel();
    Get.offAllNamed(Routes.main);
  }

  @override
  void onClose() {
    _checkAdTimer?.cancel();
    _progressTimer?.cancel();
    super.onClose();
  }
}
