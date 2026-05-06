import 'dart:async';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/consent_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
      commonDebugPrint('LaunchController: 7 seconds timeout reached. Navigating to main.');
      _navigateToMain();
    });

    // 3. 拉取远端配置
    bool fetchSuccess = await RemoteConfigManager().fetchAndActivateConfig();

    // 如果拉取失败或者配置为空，直接跳转 main
    if (!fetchSuccess || RemoteConfigManager().config == null) {
      commonDebugPrint('LaunchController: Failed to fetch config or config is null. Navigating to main.');
      _navigateToMain();
      return;
    }

    // 4. 收集隐私合规 (UMP) 并初始化 MobileAds
    ConsentManager.instance.gatherConsent((formError) async {
      if (formError != null) {
        commonDebugPrint('LaunchController: gatherConsent error: ${formError.message}');
      }
      
      // 检查用户是否同意了广告请求
      bool canRequestAds = await ConsentManager.instance.canRequestAds();
      if (canRequestAds) {
        // 初始化 AdMob SDK
        await MobileAds.instance.initialize();
        commonDebugPrint('LaunchController: MobileAds initialized successfully.');
        
        // 5. 根据配置分别加载各个场景的广告
        final config = RemoteConfigManager().config!;
        AdManager.instance.loadAd('open', config.open);
        AdManager.instance.loadAd('behavior', config.behavior);
        AdManager.instance.loadAd('NVhome', config.nvhome);

        // 6. 尝试轮询展示 open 广告
        _tryShowOpenAd();
      } else {
        commonDebugPrint('LaunchController: User did not consent to ads. Navigating to main.');
        _navigateToMain();
      }
    });
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
