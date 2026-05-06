import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/consent_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 原生广告（Native Ad）管理器
///
/// 职责：
/// - 负责通过 AdMob SDK 实际加载原生类型的广告，并配置其展示样式模板（[NativeTemplateStyle]）。
/// - 管理不同场景（scenario）下的广告实例和加载状态。
/// - 当加载失败时，与外层的 [AdManager] 联动；同时提供加载完成/全部失败的回调供 UI 层更新视图。
class NativeAdManager {
  /// 单例模式，方便全局统一管理多场景原生广告
  static final NativeAdManager instance = NativeAdManager._internal();

  factory NativeAdManager() => instance;

  NativeAdManager._internal();

  /// 缓存每个场景加载成功的原生广告实例
  final Map<String, NativeAd> _nativeAds = {};
  /// 记录每个场景是否已成功加载原生广告
  final Map<String, bool> _isAdLoadedMap = {};
  /// 记录每个场景是否正在加载原生广告中，防止重复发起请求
  final Map<String, bool> _isAdLoadingMap = {};

  /// 缓存每个场景对应的加载成功回调，供 UI 层监听并重绘 Widget
  final Map<String, Function(String scenario)> onAdLoadedCallbacks = {};
  /// 缓存每个场景对应的加载失败回调，供 UI 层处理异常情况
  final Map<String, Function(String scenario, LoadAdError error)> onAdFailedCallbacks = {};
  /// 缓存每个场景对应的广告关闭回调，供外部重新发起加载或做其他处理
  final Map<String, Function(String scenario)> onCloseCallbacks = {};

  /// 为特定场景设置加载成功或失败的回调监听
  ///
  /// UI 层（如 StatefulWidget）在渲染前应当调用此方法注册回调，以便在广告数据返回后刷新界面。
  void setListener(
    String scenario, {
    Function(String scenario)? onAdLoaded,
    Function(String scenario, LoadAdError error)? onAdFailed,
    Function(String scenario)? onAdClosed,
  }) {
    if (onAdLoaded != null) onAdLoadedCallbacks[scenario] = onAdLoaded;
    if (onAdFailed != null) onAdFailedCallbacks[scenario] = onAdFailed;
    if (onAdClosed != null) onCloseCallbacks[scenario] = onAdClosed;
  }

  /// 尝试加载单个广告配置项
  ///
  /// 由统一的 [AdManager] 调度调用。如果当前加载失败，会触发 [onFailed] 回调，
  /// 通知 [AdManager] 继续尝试下一个优先级的配置项。
  void loadAdItem(
    String scenario,
    AdItem item, {
    required VoidCallback onFailed,
    TemplateType templateType = TemplateType.medium,
  }) async {
    // 检查是否已经获得了用户的广告授权同意
    var canRequestAds = await ConsentManager.instance.canRequestAds();
    if (!canRequestAds) {
      onFailed();
      return;
    }

    if (isAdLoading(scenario)) {
      commonDebugPrint('NativeAdManager: NativeAd for scenario $scenario is already loading. Ignored duplicate request.');
      return;
    }

    _isAdLoadingMap[scenario] = true;

    final ad = NativeAd(
      adUnitId: item.placementid,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          commonDebugPrint('NativeAdManager: NativeAd ${item.placementid} loaded for scenario: $scenario.');
          // 加载成功，记录广告实例和可用状态
          _nativeAds[scenario] = ad as NativeAd;
          _isAdLoadedMap[scenario] = true;
          _isAdLoadingMap[scenario] = false;
          // 通知 UI 层广告已加载完毕，可以提取并渲染了
          if (onAdLoadedCallbacks.containsKey(scenario)) {
            onAdLoadedCallbacks[scenario]!(scenario);
          }
        },
        onAdFailedToLoad: (ad, error) {
          commonDebugPrint('NativeAdManager: NativeAd ${item.placementid} failed to load for scenario $scenario: $error');
          // 加载失败，释放废弃实例
          ad.dispose();
          _isAdLoadingMap[scenario] = false;
          // 通知调度器继续尝试加载下一个配置
          onFailed();
        },
        onAdClicked: (ad) {},
        onAdImpression: (ad) {},
        onAdClosed: (ad) {
          commonDebugPrint('NativeAdManager: NativeAd ${item.placementid} closed for scenario: $scenario');
          // 原生广告被关闭/销毁时，释放掉已经被关闭的广告
          disposeAd(scenario);
          
          // 如果外层有通过 setListener 注册关闭监听，则触发回调通知外部（可用于触发新一轮加载等）
          if (onCloseCallbacks.containsKey(scenario)) {
            onCloseCallbacks[scenario]!(scenario);
          }
        },
        onAdOpened: (ad) {},
        onAdWillDismissScreen: (ad) {},
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
      ),
      request: const AdRequest(),
      // 配置原生广告的 UI 样式模板
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: templateType,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    );

    // 发起网络请求加载广告数据
    ad.load();
  }

  /// 供 [AdManager] 调用，通知当前场景下所有权重的原生广告项均已加载失败
  void notifyAdFailed(String scenario) {
    if (onAdFailedCallbacks.containsKey(scenario)) {
      onAdFailedCallbacks[scenario]!(
        scenario,
        LoadAdError(0, 'NativeAdManager', 'All ad units failed to load for scenario $scenario', null),
      );
    }
  }

  /// 检查指定场景的原生广告是否已加载并可用
  bool isAdLoaded(String scenario) {
    return _isAdLoadedMap[scenario] ?? false;
  }

  /// 检查指定场景的原生广告是否正在加载中
  bool isAdLoading(String scenario) {
    return _isAdLoadingMap[scenario] ?? false;
  }

  /// 获取指定场景加载好的原生广告实例
  ///
  /// UI 层应调用此方法获取实例，并将其传入 `AdWidget(ad: ...)` 中进行渲染展示。
  NativeAd? getNativeAd(String scenario) {
    return _nativeAds[scenario];
  }

  /// 销毁并清理指定场景的广告实例及其状态
  ///
  /// 注意：当包含 `AdWidget` 的页面被销毁时，应当主动调用此方法释放内存。
  void disposeAd(String scenario) {
    _nativeAds[scenario]?.dispose();
    _nativeAds.remove(scenario);
    _isAdLoadedMap[scenario] = false;
    _isAdLoadingMap.remove(scenario);
  }

  /// 销毁所有缓存的广告实例（常用于应用退出或重置时）
  void disposeAll() {
    for (var ad in _nativeAds.values) {
      ad.dispose();
    }
    _nativeAds.clear();
    _isAdLoadedMap.clear();
    _isAdLoadingMap.clear();
  }
}
