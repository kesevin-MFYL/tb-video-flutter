import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:get/get.dart';

mixin VideoAdMixin on GetxController {
  String? _showNativeAdScenario;

  bool get isShowingNativeAd => _showNativeAdScenario != null;

  String? get nativeAdScenario => _showNativeAdScenario;

  bool _isShowingSecondAd = false;

  /// 所有广告关闭
  void allAdClosed() {}

  /// 多广告展示逻辑判断
  bool tryShowDualAds() {
    _isShowingSecondAd = false;

    bool hasLevelH = AdManager.instance.isAdAvailable('level_h');
    bool hasBh1 = AdManager.instance.isAdAvailable('behavior');
    bool hasBh2 = AdManager.instance.isAdAvailable('behavior2');

    if (!hasLevelH && !hasBh1 && !hasBh2) {
      return false;
    }

    // 第一阶段：确定并展示第一个广告
    if (hasLevelH) {
      commonDebugPrint('VideoAdMixin: 准备展示首个广告 - level_h');
      // 优先公共高价
      if (NativeAdManager.instance.isAdLoaded('level_h')) {
        handleNativeAd('level_h');
      } else {
        AdManager.instance.showAdIfAvailable(
          'level_h',
          ignoreInterval: true,
          onAdDismissed: () {
            commonDebugPrint('VideoAdMixin: 首个广告 (level_h) 关闭');
            _checkAndShowSecondAd('level_h');
          },
        );
      }
      // 如果bh1或bh2没就绪，同时顺便请求一下，为第二广告位做准备
      if (!hasBh1) requestAd('behavior');
      if (!hasBh2) requestAd('behavior2');
      return true;
    } else if (hasBh1) {
      commonDebugPrint('VideoAdMixin: 准备展示首个广告 - behavior');
      if (NativeAdManager.instance.isAdLoaded('behavior')) {
        handleNativeAd('behavior');
      } else {
        AdManager.instance.showAdIfAvailable(
          'behavior',
          ignoreInterval: true,
          onAdDismissed: () {
            commonDebugPrint('VideoAdMixin: 首个广告 (behavior) 关闭');
            _checkAndShowSecondAd('behavior');
          },
        );
      }
      if (!hasBh2) requestAd('behavior2');
      return true;
    } else if (hasBh2) {
      commonDebugPrint('VideoAdMixin: 准备展示首个广告 - behavior2');
      if (NativeAdManager.instance.isAdLoaded('behavior2')) {
        handleNativeAd('behavior2');
      } else {
        AdManager.instance.showAdIfAvailable(
          'behavior2',
          ignoreInterval: true,
          onAdDismissed: () {
            commonDebugPrint('VideoAdMixin: 首个广告 (behavior2) 关闭');
            _checkAndShowSecondAd('behavior2');
          },
        );
      }
      if (!hasBh1) requestAd('behavior');
      return true;
    }

    commonDebugPrint('VideoAdMixin: 没有可展示的首个广告');
    return false;
  }

  /// 第二阶段：检查并展示第二个广告
  void _checkAndShowSecondAd(String? firstScenario) {
    _isShowingSecondAd = true;

    if (AdManager.instance.isAdAvailable('level_h')) {
      commonDebugPrint('VideoAdMixin: 准备展示第二接力广告 - level_h');
      if (NativeAdManager.instance.isAdLoaded('level_h')) {
        handleNativeAd('level_h');
      } else {
        AdManager.instance.showAdIfAvailable(
          'level_h',
          ignoreInterval: true,
          onAdDismissed: () {
            commonDebugPrint('VideoAdMixin: 第二接力广告 (level_h) 关闭，结束所有广告流程');
            _isShowingSecondAd = false;
            allAdClosed();
          },
        );
      }
    } else if (AdManager.instance.isAdAvailable('behavior') && firstScenario != 'behavior') {
      commonDebugPrint('VideoAdMixin: 准备展示第二接力广告 - behavior');
      if (NativeAdManager.instance.isAdLoaded('behavior')) {
        handleNativeAd('behavior');
      } else {
        AdManager.instance.showAdIfAvailable(
          'behavior',
          ignoreInterval: true,
          onAdDismissed: () {
            commonDebugPrint('VideoAdMixin: 第二接力广告 (behavior) 关闭，结束所有广告流程');
            _isShowingSecondAd = false;
            allAdClosed();
          },
        );
      }
    } else if (AdManager.instance.isAdAvailable('behavior2') && firstScenario != 'behavior2') {
      commonDebugPrint('VideoAdMixin: 准备展示第二接力广告 - behavior2');
      if (NativeAdManager.instance.isAdLoaded('behavior2')) {
        handleNativeAd('behavior2');
      } else {
        AdManager.instance.showAdIfAvailable(
          'behavior2',
          ignoreInterval: true,
          onAdDismissed: () {
            commonDebugPrint('VideoAdMixin: 第二接力广告 (behavior2) 关闭，结束所有广告流程');
            _isShowingSecondAd = false;
            allAdClosed();
          },
        );
      }
    } else {
      commonDebugPrint('VideoAdMixin: 没有可展示的第二接力广告，直接结束流程');
      _isShowingSecondAd = false;
      allAdClosed();
    }
  }

  /// 切换原生广告显示状态
  void handleNativeAd(String scenario) {
    commonDebugPrint('VideoAdMixin: 将要渲染原生全屏广告控件 - $scenario');
    _showNativeAdScenario = scenario;
    AdManager.instance.markAdShowing(true);
    update();
  }

  /// 关闭原生广告，判断是否最后一个广告，如果是关闭并执行下一步，否则继续展示下一个广告
  void closeNativeAd() {
    if (_showNativeAdScenario != null) {
      String scenario = _showNativeAdScenario!;
      commonDebugPrint('VideoAdMixin: 用户手动关闭原生全屏广告 - $scenario');
      NativeAdManager.instance.disposeAd(scenario);
      _showNativeAdScenario = null;
      AdManager.instance.markAdShowing(false);
      AdManager.instance.updateLastAdShowTime();
      update();

      // 原生广告关闭后，需要重新拉取新的广告
      commonDebugPrint('VideoAdMixin: 为关闭的原生场景 $scenario 重新拉取新缓存');
      requestAd(scenario);

      if (_isShowingSecondAd) {
        // 这是第二顺位的原生广告，展示结束直接播放视频
        commonDebugPrint('VideoAdMixin: 刚关闭的是第二顺位的原生接力广告，流程结束，准备播放视频');
        _isShowingSecondAd = false;
        allAdClosed();
        return;
      }

      // Check if we need to show the second ad
      if (scenario == 'level_h' || scenario == 'behavior' || scenario == 'behavior2') {
        commonDebugPrint('VideoAdMixin: 刚关闭的是首个原生广告，开始检查是否有接力广告');
        _checkAndShowSecondAd(scenario);
      } else {
        allAdClosed();
      }
    }
  }

  /// 请求广告
  void requestAd(String scenario) {
    final config = RemoteConfigManager().config;
    if (config != null) {
      commonDebugPrint('VideoAdMixin: 触发请求广告 - $scenario');
      if (scenario == 'behavior') AdManager.instance.loadAd('behavior', config.behavior);
      if (scenario == 'behavior2') AdManager.instance.loadAd('behavior2', config.behavior2);
      if (scenario == 'level_h') AdManager.instance.loadAd('level_h', config.levelH);
      if (scenario == 'pause') AdManager.instance.loadAd('pause', config.pause);
    }
  }
}
