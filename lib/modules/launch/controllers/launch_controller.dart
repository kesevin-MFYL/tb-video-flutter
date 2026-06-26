import 'dart:async';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/admob/consent_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/manager/switch_manager.dart';
import 'package:editvideo/routes/app_routes.dart';
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
        commonDebugPrint('测试日志：7秒超时，跳转主页');
        // 进度条满（即7秒超时），强行跳转主页
        commonDebugPrint('LaunchController: 7 seconds timeout reached. Navigating to main.');
        _navigateToMain();
      } else {
        update();
      }
    });
  }

  Future<void> _initializeAppAndAds() async {
    // 拉取firebase远程配置
    RemoteConfigManager().fetchAndActivateConfig();

    // 初始化 RemoteConfig 设置
    await RemoteConfigManager().initialize();

    // // 3. 收集隐私合规 (UMP) 并初始化 MobileAds
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
    commonDebugPrint('测试日志：获取到广告授权 开始拉取广告');
    _isMobileAdsInitializeCalled = true;

    // 初始化 AdMob SDK
    MobileAds.instance.initialize();

    // 5. 根据配置分别加载各个场景的广告
    final config = RemoteConfigManager().config!;
    AdManager.instance.loadAd('level_h', config.levelH);
    AdManager.instance.loadAd('open', config.open);
    AdManager.instance.loadAd('behavior', config.behavior);
    AdManager.instance.loadAd('behavior2', config.behavior2);
    AdManager.instance.loadAd('NVhome', config.nvhome);

    // 6. 尝试轮询展示广告
    _tryShowAd();
  }

  String? _showNativeAdScenario;
  bool get isShowingNativeAd => _showNativeAdScenario != null;
  String? get nativeAdScenario => _showNativeAdScenario;

  void _tryShowAd() {
    // 循环检查广告是否准备就绪，每隔 500 毫秒检查一次，直到超时
    _checkAdTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_hasNavigatedToMain) {
        timer.cancel();
        return;
      }

      if (AdManager.instance.isAdAvailable('level_h')) {
        _handleAdReady('level_h', timer);
      } else if (!AdManager.instance.isAdLoading('level_h')) {
        if (AdManager.instance.isAdAvailable('open')) {
          _handleAdReady('open', timer);
        } else if (!AdManager.instance.isAdLoading('open')) {
          // level_h 和 open 均已加载失败，可以考虑提前进入主页，但此处交由 7 秒超时处理也可以
        }
      }
    });
  }

  void _handleAdReady(String scenario, Timer timer) {
    timer.cancel();
    _progressTimer?.cancel();
    progress = 1.0;
    update();

    if (NativeAdManager.instance.isAdLoaded(scenario)) {
      commonDebugPrint('LaunchController: Native ad is ready for $scenario. Showing in LaunchPage.');
      _showNativeAdScenario = scenario;
      AdManager.instance.markAdShowing(true);
      update();
    } else {
      commonDebugPrint('LaunchController: Other ad is ready for $scenario. Showing ad.');
      AdManager.instance.showAdIfAvailable(
        scenario,
        onAdDismissed: () {
          commonDebugPrint('LaunchController: Ad dismissed. Navigating to main.');
          _navigateToMain();
        },
      );
    }
  }

  void closeNativeAd() {
    if (_showNativeAdScenario != null) {
      NativeAdManager.instance.disposeAd(_showNativeAdScenario!);
      AdManager.instance.markAdShowing(false);

      // Reload ad for next time
      final config = RemoteConfigManager().config;
      if (config != null) {
        if (nativeAdScenario == 'level_h') {
          AdManager.instance.loadAd('level_h', config.levelH);
        } else if (nativeAdScenario == 'open') {
          AdManager.instance.loadAd('open', config.open);
        }
      }
    }
    _navigateToMain();
  }

  void _navigateToMain() {
    if (_hasNavigatedToMain) return;
    _hasNavigatedToMain = true;
    SwitchManager.instance.excutePage();
    _checkAdTimer?.cancel();
    _progressTimer?.cancel();
    Get.offAllNamed(SwitchManager.instance.canToB.value ? Routes.mainB : Routes.mainA);
  }

  @override
  void onClose() {
    _checkAdTimer?.cancel();
    _progressTimer?.cancel();
    super.onClose();
  }
}
