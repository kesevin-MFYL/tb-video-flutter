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

      String? scenarioToShow;
      if (AdManager.instance.isAdAvailable('level_h')) {
        scenarioToShow = 'level_h';
      } else if (AdManager.instance.isAdAvailable('open')) {
        scenarioToShow = 'open';
      }

      if (scenarioToShow != null) {
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
      }
    }
  }

  void _showNativeAdDialog(String scenario) {
    final nativeAd = NativeAdManager.instance.getNativeAd(scenario);
    if (nativeAd == null) {
      return;
    }

    AdManager.instance.markAdShowing(true);

    late StreamSubscription<EventBusModel> closeNativeAdSubscription;
    
    void closeDialog() {
      Get.back();
      AdManager.instance.markAdShowing(false);
      NativeAdManager.instance.disposeAd(scenario);
      commonDebugPrint('AdManager: app从后台切换回前台，关闭原生广告');
      EventBusManager.instance.post(EventBusName.playVideo);
      closeNativeAdSubscription.cancel();
      
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

    closeNativeAdSubscription = EventBusManager.instance.addObserver(EventBusName.closeNativeAd, (value) async {
      closeDialog();
    });

    Get.dialog(
      PopScope(
        canPop: false,
        child: Material(
          color: CommonColors.color060600,
          child: Stack(
            children: [
              AdWidget(ad: nativeAd),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    closeDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '跳过',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      useSafeArea: false,
      barrierDismissible: false,
    );
  }
}
