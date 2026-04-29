import 'package:editvideo/manager/admob/consent_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 开屏广告（App Open Ad）管理器
///
/// 职责：
/// - 负责通过 AdMob SDK 实际加载和展示开屏类型的广告。
/// - 管理不同场景（scenario）下的广告实例和缓存状态。
/// - 当加载失败或被关闭时，与外层的 [AdManager] 联动。
class AppOpenAdManager {
  /// 单例模式，方便全局统一管理多场景开屏广告
  static final AppOpenAdManager instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => instance;
  AppOpenAdManager._internal();

  /// 开屏广告缓存的有效时长（当前业务设置为 1 小时过期）
  final Duration maxCacheDuration = const Duration(hours: 1);

  /// 缓存每个场景的广告加载时间，用于判断是否过期
  final Map<String, DateTime> _appOpenLoadTimes = {};
  
  /// 缓存每个场景加载成功的广告实例
  final Map<String, AppOpenAd> _appOpenAds = {};
  
  /// 标记当前是否正在展示广告，防止重复展示
  bool _isShowingAd = false;

  /// 尝试加载单个广告配置项
  ///
  /// 由统一的 [AdManager] 调度调用。如果当前加载失败，会触发 [onFailed] 回调，
  /// 通知 [AdManager] 继续尝试下一个优先级的配置项。
  void loadAdItem(String scenario, AdItem item, {required VoidCallback onFailed}) async {
    // 检查是否已经获得了用户的广告授权同意
    // var canRequestAds = await ConsentManager.instance.canRequestAds();
    // if (!canRequestAds) {
    //   onFailed();
    //   return;
    // }

    AppOpenAd.load(
      adUnitId: item.placementid,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd ${item.placementid} loaded for scenario: $scenario');
          // 加载成功，记录加载时间和广告实例
          _appOpenLoadTimes[scenario] = DateTime.now();
          _appOpenAds[scenario] = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd ${item.placementid} failed to load for scenario $scenario: $error');
          // 加载失败，通知调度器继续下一个
          onFailed();
        },
      ),
    );
  }

  /// 检查指定场景的开屏广告是否已加载并可用
  bool isAdAvailable(String scenario) {
    return _appOpenAds.containsKey(scenario) && _appOpenAds[scenario] != null;
  }

  /// 展示指定场景的广告
  ///
  /// [onAdDismissed]：由 [AdManager] 传入的回调，用于在广告被关闭或因过期丢弃时触发重新加载逻辑。
  void showAdIfAvailable(String scenario, {VoidCallback? onAdDismissed}) {
    if (!isAdAvailable(scenario)) {
      debugPrint('Tried to show ad before available for scenario: $scenario.');
      if (onAdDismissed != null) onAdDismissed();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }

    // 检查广告是否已经过期（超过 1 小时）
    final loadTime = _appOpenLoadTimes[scenario];
    if (loadTime != null && DateTime.now().subtract(maxCacheDuration).isAfter(loadTime)) {
      debugPrint('Maximum cache duration exceeded for scenario: $scenario. Loading another ad.');
      disposeAd(scenario);
      if (onAdDismissed != null) onAdDismissed();
      return;
    }

    // 取出对应场景的广告实例
    final ad = _appOpenAds[scenario]!;
    
    // 设置全屏内容的回调监听
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent for scenario: $scenario');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent for scenario $scenario: $error');
        _isShowingAd = false;
        disposeAd(scenario); // 展示失败时销毁并清理缓存
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent for scenario: $scenario');
        _isShowingAd = false;
        disposeAd(scenario); // 用户关闭广告后销毁并清理缓存
        if (onAdDismissed != null) onAdDismissed(); // 触发回调通知调度器重新拉取备用广告
      },
    );
    
    // 实际调用 AdMob 的 show 方法
    ad.show();
  }

  /// 销毁并清理指定场景的广告实例及其状态
  void disposeAd(String scenario) {
    _appOpenAds[scenario]?.dispose();
    _appOpenAds.remove(scenario);
    _appOpenLoadTimes.remove(scenario);
  }
}
