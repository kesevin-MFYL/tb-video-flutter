import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:get/get.dart';

mixin VideoAdMixin on GetxController {
  String? _showNativeAdScenario;
  bool get isShowingNativeAd => _showNativeAdScenario != null;
  String? get nativeAdScenario => _showNativeAdScenario;

  bool _isShowingSecondAd = false;

  /// 所有广告关闭
  void allAdClosed(){}

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
      // 优先公共高价
      if (NativeAdManager.instance.isAdLoaded('level_h')) {
        handleNativeAd('level_h');
      } else {
        AdManager.instance.showAdIfAvailable('level_h', onAdDismissed: () {
          _checkAndShowSecondAd('level_h');
        });
      }
      // 如果bh1或bh2没就绪，同时顺便请求一下，为第二广告位做准备
      if (!hasBh1) requestAd('behavior');
      if (!hasBh2) requestAd('behavior2');
      return true;
    } else if (hasBh1) {
      if (NativeAdManager.instance.isAdLoaded('behavior')) {
        handleNativeAd('behavior');
      } else {
        AdManager.instance.showAdIfAvailable('behavior', onAdDismissed: () {
          _checkAndShowSecondAd('behavior');
        });
      }
      if (!hasBh2) requestAd('behavior2');
      return true;
    } else if (hasBh2) {
      if (NativeAdManager.instance.isAdLoaded('behavior2')) {
        handleNativeAd('behavior2');
      } else {
        AdManager.instance.showAdIfAvailable('behavior2', onAdDismissed: () {
          _checkAndShowSecondAd('behavior2');
        });
      }
      if (!hasBh1) requestAd('behavior');
      return true;
    }

    return false;
  }

  /// 第二阶段：检查并展示第二个广告
  void _checkAndShowSecondAd(String? firstScenario) {
    _isShowingSecondAd = true;

    if (AdManager.instance.isAdAvailable('level_h')) {
      if (NativeAdManager.instance.isAdLoaded('level_h')) {
        handleNativeAd('level_h');
      } else {
        AdManager.instance.showAdIfAvailable('level_h', onAdDismissed: () {
          _isShowingSecondAd = false;
          allAdClosed();
        });
      }
    } else if (AdManager.instance.isAdAvailable('behavior') && firstScenario != 'behavior') {
      if (NativeAdManager.instance.isAdLoaded('behavior')) {
        handleNativeAd('behavior');
      } else {
        AdManager.instance.showAdIfAvailable('behavior', onAdDismissed: () {
          _isShowingSecondAd = false;
          allAdClosed();
        });
      }
    } else if (AdManager.instance.isAdAvailable('behavior2') && firstScenario != 'behavior2') {
      if (NativeAdManager.instance.isAdLoaded('behavior2')) {
        handleNativeAd('behavior2');
      } else {
        AdManager.instance.showAdIfAvailable('behavior2', onAdDismissed: () {
          _isShowingSecondAd = false;
          allAdClosed();
        });
      }
    } else {
      _isShowingSecondAd = false;
      allAdClosed();
    }
  }

  /// 关闭原生广告，判断是否最后一个广告，如果是关闭并执行下一步，否则继续展示下一个广告
  void closeNativeAd() {
    if (_showNativeAdScenario != null) {
      String scenario = _showNativeAdScenario!;
      NativeAdManager.instance.disposeAd(scenario);
      _showNativeAdScenario = null;
      update();

      // 原生广告关闭后，需要重新拉取新的广告
      requestAd(scenario);

      if (_isShowingSecondAd) {
        // 这是第二顺位的原生广告，展示结束直接播放视频
        _isShowingSecondAd = false;
        allAdClosed();
        return;
      }

      // Check if we need to show the second ad
      if (scenario == 'level_h' || scenario == 'behavior' || scenario == 'behavior2') {
         _checkAndShowSecondAd(scenario);
      } else {
        allAdClosed();
      }
    }
  }

  /// 切换原生广告显示状态
  void handleNativeAd(String scenario) {
    _showNativeAdScenario = scenario;
    update();
  }

  /// 请求广告
  void requestAd(String scenario) {
    final config = RemoteConfigManager().config;
    if (config != null) {
      if (scenario == 'behavior') AdManager.instance.loadAd('behavior', config.behavior);
      if (scenario == 'behavior2') AdManager.instance.loadAd('behavior2', config.behavior2);
      if (scenario == 'level_h') AdManager.instance.loadAd('level_h', config.levelH);
    }
  }
}