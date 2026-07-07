import 'dart:async';
import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppLifecycleReactor {
  static final AppLifecycleReactor instance = AppLifecycleReactor._internal();
  factory AppLifecycleReactor() => instance;
  AppLifecycleReactor._internal();

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    commonDebugPrint('New AppState state: $appState');
    if (appState == AppState.foreground) {
      // 如果当前已有任何全屏或原生广告正在展示，切前台时不再展示热启动广告
      if (AdManager.instance.isAnyAdShowing) {
        commonDebugPrint('AdManager: app从后台切换回前台，但当前已有广告正在展示，跳过热启动广告');
        return;
      }

      // 判断是否在时间间隔内
      if (!AdManager.instance.canShowAdBasedOnInterval()) {
        commonDebugPrint('AdManager: app从后台切换回前台，但在广告全局间隔内，跳过热启动广告');
        return;
      }

      bool hasLevelH = AdManager.instance.isAdAvailable('level_h');
      bool hasOpen = AdManager.instance.isAdAvailable('open');

      String? scenarioToShow;
      if (hasLevelH) {
        scenarioToShow = 'level_h';
      } else if (hasOpen) {
        scenarioToShow = 'open';
      }

      if (scenarioToShow != null) {
        if (!hasLevelH) {
          commonDebugPrint('AdManager: app从后台切换回前台 - 但level_h场景下无广告，重新拉取');
          requestAd('level_h');
        }

        if (NativeAdManager.instance.isAdLoaded(scenarioToShow)) {
          commonDebugPrint('AdManager: app从后台切换回前台，展示原生全屏广告：$scenarioToShow');
          _showNativeAdDialog(scenarioToShow);
        } else {
          commonDebugPrint('AdManager: app从后台切换回前台，展示广告：$scenarioToShow');
          AdManager.instance.showAdIfAvailable(scenarioToShow, onAdDismissed: () {
            commonDebugPrint('AdManager: app从后台切换回前台，关闭广告事件');
            EventBusManager.instance.post(EventBusName.playVideo);
          });
        }
      } else {
        commonDebugPrint('AdManager: app从后台切换回前台，没有可用广告');
        requestAd('level_h');
        requestAd('open');
      }
    }
  }

  void _showNativeAdDialog(String scenario) {
    final nativeAd = NativeAdManager.instance.getNativeAd(scenario);
    if (nativeAd == null) {
      return;
    }

    AdManager.instance.markAdShowing(true);

    late StreamSubscription<EventBusModel> closeFullscreenNativeAdSubscription;
    
    void closeDialog() {
      Get.back();
      AdManager.instance.markAdShowing(false);
      NativeAdManager.instance.disposeAd(scenario);
      AdManager.instance.updateLastAdShowTime();
      commonDebugPrint('AdManager: app从后台切换回前台，关闭原生广告');
      EventBusManager.instance.post(EventBusName.playVideo);
      closeFullscreenNativeAdSubscription.cancel();
      
      // Reload ad for next time
      final config = RemoteConfigManager().config;
      if (config != null) {
        if (scenario == 'level_h') {
          AdManager.instance.loadAd('level_h', config.levelH);
        } else if (scenario == 'open') {
          AdManager.instance.loadAd('open', config.open);
        }
      }
    }

    closeFullscreenNativeAdSubscription = EventBusManager.instance.addObserver(EventBusName.closeFullscreenNativeAd, (value) async {
      closeDialog();
    });

    // 原生全屏展示前先暂停播放
    EventBusManager.instance.post(EventBusName.pauseVideo);

    Get.dialog(
      PopScope(
        canPop: false,
        child: Material(
          color: CommonColors.color060600,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: AdWidget(ad: nativeAd),
          ),
        ),
      ),
      useSafeArea: false,
      barrierDismissible: false,
    );
  }

  /// 请求广告
  void requestAd(String scenario) {
    final config = RemoteConfigManager().config;
    if (config != null) {
      commonDebugPrint('AdManager: 触发请求广告 - $scenario');
      if (scenario == 'level_h') AdManager.instance.loadAd('level_h', config.levelH);
      if (scenario == 'open') AdManager.instance.loadAd('open', config.open);
    }
  }
}
