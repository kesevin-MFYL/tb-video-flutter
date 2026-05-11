import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/app_open_ad_manager.dart';
import 'package:editvideo/manager/admob/interstitial_ad_manager.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:flutter/material.dart';

/// 全局广告调度管理类
///
/// 职责：
/// - 接收来自远端的广告配置列表（`AdItem`）。
/// - 根据不同场景（`scenario`），将加载任务分发给对应的具体广告管理器（如开屏、插屏、原生）。
/// - 遵循优先级降序机制：如果当前高优先级的广告加载失败，会自动尝试列表中下一个优先级的广告，直至加载成功或全部失败。
class AdManager {
  /// 单例实例，确保全局统一调度
  static final AdManager instance = AdManager._internal();
  factory AdManager() => instance;
  AdManager._internal();

  /// 缓存每个场景的广告配置列表，主要用于广告展示完毕（关闭）后，自动重新发起下一轮加载
  final Map<String, List<AdItem>> _scenarioAdItems = {};

  /// 标记某个场景的广告配置队列是否正在执行整体的加载循环流程
  final Map<String, bool> _isScenarioLoading = {};

  /// 标记当前是否全局正在展示某个全屏广告（防止重叠展示）
  bool _isAnyFullScreenAdShowing = false;

  /// 记录上一次全局展示全屏广告（open/interstitial）的时间戳
  DateTime? _lastFullScreenAdShowTime;

  void prepareAdItems(String scenario, List<AdItem> adItems) {
    if (adItems.isEmpty) {
      commonDebugPrint('AdManager: No valid ad items for scenario: $scenario');
      return;
    }
    // 缓存当前场景配置
    _scenarioAdItems[scenario] = adItems;
  }

  /// 针对指定场景加载广告
  ///
  /// [scenario] 场景名称（例如：'open'、'behavior' 等）
  /// [adItems]  该场景下的广告配置列表（建议按 `adweight` 降序排列好传入）
  void loadAd(String scenario, List<AdItem> adItems) {
    if (adItems.isEmpty) {
      commonDebugPrint('测试日志：当前场景无有效广告项');
      commonDebugPrint('AdManager: No valid ad items for scenario: $scenario');
      return;
    }

    // 缓存当前场景配置
    _scenarioAdItems[scenario] = adItems;
    
    // 如果当前场景的广告配置循环还在处理中，则阻止后续并发请求，防止冲突
    if (_isScenarioLoading[scenario] == true) {
      commonDebugPrint('AdManager: Scenario $scenario is already in the loading process. Ignored concurrent request.');
      return;
    }

    // 锁定该场景的加载状态
    _isScenarioLoading[scenario] = true;

    // 每次重新发起场景加载前，清除该场景下已有的旧广告缓存，防止数据串台
    AppOpenAdManager.instance.disposeAd(scenario);
    InterstitialAdManager.instance.disposeAd(scenario);
    NativeAdManager.instance.disposeAd(scenario);
    
    // 从优先级最高（index = 0）的配置项开始尝试加载
    _loadAdFromItems(scenario, adItems, 0);
  }

  /// 内部递归/迭代方法，用于按顺序（优先级）加载配置列表中的广告项
  void _loadAdFromItems(String scenario, List<AdItem> items, int index) {
    // 如果索引超出了列表长度，说明所有配置项都尝试完毕且全部失败
    if (index >= items.length) {
      commonDebugPrint('测试日志：场景-$scenario: 未拉取到任何广告');
      commonDebugPrint('AdManager: All ad items failed to load for scenario: $scenario.');
      // 释放锁
      _isScenarioLoading[scenario] = false;
      // 通知原生广告的监听器，当前场景所有广告加载失败
      NativeAdManager.instance.notifyAdFailed(scenario);
      return;
    }

    final currentItem = items[index];
    commonDebugPrint('测试日志：场景-$scenario: 正在尝试加载广告项: 广告类型:${currentItem.adtype}--广告id: ${currentItem.placementid}--优先级：${currentItem.adweight}');
    commonDebugPrint('AdManager: attempting to load adtype: ${currentItem.adtype} for scenario: $scenario (weight: ${currentItem.adweight})');

    // 闭包方法：当前广告项加载失败时触发，自动索引加一并尝试下一个配置项
    void onFailed() {
      commonDebugPrint('测试日志：场景-$scenario: 广告项加载失败，广告类型:${currentItem.adtype}--广告id: ${currentItem.placementid}--优先级：${currentItem.adweight}--尝试下一个配置项');
      commonDebugPrint('AdManager: adtype ${currentItem.adtype} failed for scenario $scenario, trying next...');
      _loadAdFromItems(scenario, items, index + 1);
    }
    
    // 闭包方法：当前广告加载成功时触发，解除整个场景的队列锁
    void onSuccess() {
      _isScenarioLoading[scenario] = false;
    }

    // 根据当前配置项的 `adtype`，将任务分发给对应的具体管理器执行
    switch (currentItem.adtype) {
      case 'open':
        AppOpenAdManager.instance.loadAdItem(scenario, currentItem, onFailed: onFailed, onSuccess: onSuccess);
        break;
      case 'interstitial':
        InterstitialAdManager.instance.loadAdItem(scenario, currentItem, onFailed: onFailed, onSuccess: onSuccess);
        break;
      case 'native':
        NativeAdManager.instance.loadAdItem(scenario, currentItem, onFailed: onFailed, onSuccess: onSuccess);
        break;
      default:
        // 遇到未知的广告类型直接跳过，尝试下一个
        commonDebugPrint('AdManager: Unknown adtype: ${currentItem.adtype}. Skipping to next.');
        onFailed();
        break;
    }
  }

  /// 检查指定场景下是否已有任何类型的广告加载成功并准备就绪
  bool isAdAvailable(String scenario) {
    return AppOpenAdManager.instance.isAdAvailable(scenario) ||
        InterstitialAdManager.instance.isAdAvailable(scenario) ||
        NativeAdManager.instance.isAdLoaded(scenario);
  }

  /// 展示指定场景的广告
  ///
  /// 调用该方法时，调度器会检查内部哪个具体的广告管理器加载成功了，并调用其展示方法。
  /// **注意**：原生广告（NativeAd）通常是作为 Widget 嵌入 UI 中的，不适用此弹窗展示方法。
  void showAdIfAvailable(String scenario, {VoidCallback? onAdDismissed}) {
    // 检查是否有广告正在展示（主要是 open 和 behavior 场景互斥）
    if ((scenario == 'open' || scenario == 'behavior') && _isAnyFullScreenAdShowing) {
      commonDebugPrint('AdManager: Cannot show $scenario ad. Another full screen ad is already showing.');
      if (onAdDismissed != null) onAdDismissed();
      return;
    }

    // 如果没有任何可用广告，则尝试重新发起一轮加载
    if (!isAdAvailable(scenario)) {
      commonDebugPrint('测试日志：场景$scenario下没有可展示的广告--重新拉取广告');
      commonDebugPrint('AdManager: Tried to show ad before available for scenario: $scenario.');
      if (onAdDismissed != null) onAdDismissed();
      if (_scenarioAdItems.containsKey(scenario) && _scenarioAdItems[scenario]!.isNotEmpty) {
        loadAd(scenario, _scenarioAdItems[scenario]!);
      }
      return;
    }

    // 检查不同广告位展示间隔时间 (differentInterval)
    // 根据需求，同一/不同广告位的全局间隔统一使用 RemoteConfig 中的 differentInterval（默认 30s）
    // 仅全屏广告（open/interstitial）受此限制
    final config = RemoteConfigManager().config;
    final int intervalSeconds = config?.differentInterval ?? 30;

    if (_lastFullScreenAdShowTime != null) {
      final elapsed = DateTime.now().difference(_lastFullScreenAdShowTime!);
      if (elapsed.inSeconds < intervalSeconds) {
        commonDebugPrint(
          'AdManager: Cannot show full screen ad yet. Only ${elapsed.inSeconds}s elapsed, need ${intervalSeconds}s.',
        );
        if (onAdDismissed != null) onAdDismissed();
        return;
      }
    }

    // 闭包方法：当全屏广告（开屏/插屏）被用户关闭后触发，用于自动重新加载下一轮广告以备后用
    void reloadNext(bool isClosed) {
      _isAnyFullScreenAdShowing = false;
      if (isClosed) {
        commonDebugPrint('测试日志：场景$scenario下的广告已关闭--重新拉取广告');
        _lastFullScreenAdShowTime = DateTime.now();
      }
      if (onAdDismissed != null) onAdDismissed();
      if (_scenarioAdItems.containsKey(scenario) && _scenarioAdItems[scenario]!.isNotEmpty) {
        loadAd(scenario, _scenarioAdItems[scenario]!);
      }
    }

    // 优先尝试展示能够全屏展示的开屏广告
    if (AppOpenAdManager.instance.isAdAvailable(scenario)) {
      _isAnyFullScreenAdShowing = true;
      AppOpenAdManager.instance.showAdIfAvailable(
        scenario,
        onAdDismissed: reloadNext,
      );
    }
    // 其次尝试展示插屏广告
    else if (InterstitialAdManager.instance.isAdAvailable(scenario)) {
      _isAnyFullScreenAdShowing = true;
      InterstitialAdManager.instance.showAdIfAvailable(
        scenario,
        onAdDismissed: reloadNext,
      );
    }
    // 如果是原生广告，只打印提示，因为它需要通过 UI Widget 进行渲染
    else if (NativeAdManager.instance.isAdLoaded(scenario)) {
      commonDebugPrint('AdManager: Native ad is loaded for scenario $scenario, please render it via UI Widget.');
      if (onAdDismissed != null) onAdDismissed();
    }
  }
}
