import 'dart:convert';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/switch_manager.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AdItem {
  final String adsource;
  final int adweight;
  final String adtype;
  final String placementid;

  AdItem({required this.adsource, required this.adweight, required this.adtype, required this.placementid});

  factory AdItem.fromJson(Map<String, dynamic> json) {
    return AdItem(
      // 大小写兼容
      adsource: (json['adsource'] as String?)?.toLowerCase() ?? '',
      adweight: json['adweight'] as int? ?? 0,
      adtype: (json['adtype'] as String?)?.toLowerCase() ?? '',
      placementid: json['placementid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'adsource': adsource, 'adweight': adweight, 'adtype': adtype, 'placementid': placementid};
  }
}

class AdConfig {
  final int showCount;
  final int sameInterval;
  final int differentInterval;
  final int timeOut;
  final int openivtime;
  final int playPointTime;
  final List<AdItem> open;
  final List<AdItem> behavior;
  final List<AdItem> nvhome;
  final List<AdItem> levelH;
  final List<AdItem> behavior2;
  final List<AdItem> playMiddle;
  final List<AdItem> pause;

  AdConfig({
    required this.showCount,
    required this.sameInterval,
    required this.differentInterval,
    required this.timeOut,
    required this.openivtime,
    required this.playPointTime,
    required this.open,
    required this.behavior,
    required this.nvhome,
    required this.levelH,
    required this.behavior2,
    required this.playMiddle,
    required this.pause,
  });

  factory AdConfig.fromJson(Map<String, dynamic> json) {
    // 提取并按 adweight 降序排序，权重越大优先级越高
    List<AdItem> parseAndSort(List<dynamic>? list) {
      if (list == null) return [];
      final parsed = list.map((e) => AdItem.fromJson(e as Map<String, dynamic>)).toList();
      parsed.sort((a, b) => b.adweight.compareTo(a.adweight));
      return parsed;
    }

    return AdConfig(
      showCount: json['showCount'] as int? ?? 100,
      sameInterval: json['sameInterval'] as int? ?? 15,
      differentInterval: json['differentInterval'] as int? ?? 30,
      timeOut: json['timeOut'] as int? ?? 10,
      openivtime: json['openivtime'] as int? ?? 30,
      playPointTime: json['PlayPointTime'] as int? ?? 600,
      open: parseAndSort(json['open'] as List<dynamic>?),
      behavior: parseAndSort(json['behavior'] as List<dynamic>?),
      nvhome: parseAndSort(json['NVhome'] as List<dynamic>?),
      levelH: parseAndSort(json['level_h'] as List<dynamic>?),
      behavior2: parseAndSort(json['behavior2'] as List<dynamic>?),
      playMiddle: parseAndSort(json['play_middle'] as List<dynamic>?),
      pause: parseAndSort(json['pause'] as List<dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showCount': showCount,
      'sameInterval': sameInterval,
      'differentInterval': differentInterval,
      'timeOut': timeOut,
      'openivtime': openivtime,
      'PlayPointTime': playPointTime,
      'open': open.map((e) => e.toJson()).toList(),
      'behavior': behavior.map((e) => e.toJson()).toList(),
      'NVhome': nvhome.map((e) => e.toJson()).toList(),
      'level_h': levelH.map((e) => e.toJson()).toList(),
      'behavior2': behavior2.map((e) => e.toJson()).toList(),
      'play_middle': playMiddle.map((e) => e.toJson()).toList(),
      'pause': pause.map((e) => e.toJson()).toList(),
    };
  }
}

class AdClickConfig {
  final int native;
  final int fullscreenNative;

  AdClickConfig({required this.native, required this.fullscreenNative});

  factory AdClickConfig.fromJson(Map<String, dynamic> json) {
    return AdClickConfig(native: json['native'] as int? ?? 0, fullscreenNative: json['fullscreen_native'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'native': native, 'fullscreen_native': fullscreenNative};
  }
}

class RemoteConfigManager {
  static final RemoteConfigManager _instance = RemoteConfigManager._internal();

  factory RemoteConfigManager() => _instance;

  RemoteConfigManager._internal();

  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  AdConfig? _config;

  AdConfig? get config => _config;

  AdClickConfig? _adClickConfig;

  AdClickConfig? get adClickConfig => _adClickConfig;

  static String _defaultAdRulesJson = '{}';

  static String _defaultAdClickJson = '{}';

  Future<void> initialize() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/default_ad_rules.json');
      _defaultAdRulesJson = jsonString;
      final String clickJsonString = await rootBundle.loadString('assets/json/default_ad_click.json');
      _defaultAdClickJson = clickJsonString;
    } catch (e) {
      commonDebugPrint("Failed to load default_ad_rules.json: $e");
    }

    // 配置 Remote Config 的设置
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        // 设置获取配置的超时时间为7秒
        fetchTimeout: const Duration(seconds: 7),
        // 【关键】开发阶段：建议设置较短的间隔以便调试，例如 0 秒
        // 【重要】生产环境：务必遵循最低更新间隔为 1 小时 (3600 秒) 的官方建议，以避免性能问题
        minimumFetchInterval: kDebugMode ? const Duration(seconds: 0) : const Duration(hours: 1),
      ),
    );

    // 设置应用内默认参数值
    // 1. 尝试读取本地 Storage 中的缓存
    final cachedRulesJson = Storage.getAdRulesConfig();
    if (cachedRulesJson != null && cachedRulesJson.isNotEmpty) {
      commonDebugPrint("Remote config: Initialize defaults with local Storage cache.");
      _defaultAdRulesJson = cachedRulesJson; // 将缓存赋值给 _defaultAdRulesJson 作为兜底
    }

    // 设置应用内默认参数值
    // 1. 尝试读取本地 Storage 中的缓存
    final cachedClickJson = Storage.getAdClickConfig();
    if (cachedClickJson != null && cachedClickJson.isNotEmpty) {
      commonDebugPrint("Remote config: Initialize defaults with local Storage click cache.");
      _defaultAdClickJson = cachedClickJson; // 将缓存赋值给 _defaultAdClickJson 作为兜底
    }

    await remoteConfig.setDefaults({'ad_json_and': _defaultAdRulesJson});
    await remoteConfig.setDefaults({'clickbait': _defaultAdClickJson});

    // 2. 同步初始化一次内存中的 _config 对象，确保在 fetchAndActivate 之前业务层也能读取到
    parseAndCacheConfig();

    // 3. 同步初始化一次内存中的 _adClickConfig 对象，确保在 fetchAndActivate 之前业务层也能读取到
    parseAndCacheAdClickConfig();

    // 监听实时更新（Firebase 远端下发了新配置）
    _listenForUpdates();
  }

  // 监听 Firebase Remote Config 实时更新
  void _listenForUpdates() {
    remoteConfig.onConfigUpdated.listen((event) async {
      commonDebugPrint("Remote config: Received real-time update event.");
      try {
        // 激活最新配置
        await remoteConfig.activate();

        // 只有当 ad_json_and 更新时才重新加载广告
        if (event.updatedKeys.contains('ad_json_and')) {
          // 解析并缓存到内存及本地 Storage 中
          bool isSuccess = parseAndCacheConfig();

          if (isSuccess && _config != null) {
            commonDebugPrint("Remote config: Reloading all ads with updated config.");
            AdManager.instance.loadAd('level_h', _config!.levelH);
            AdManager.instance.loadAd('open', _config!.open);
            AdManager.instance.loadAd('behavior', _config!.behavior);
            AdManager.instance.loadAd('behavior2', _config!.behavior2);
            AdManager.instance.loadAd('NVhome', _config!.nvhome);
          }
        } else if (event.updatedKeys.contains('clickbait')) {
          parseAndCacheAdClickConfig();
        } else if (event.updatedKeys.contains('movix_reffer_clo') ||
            event.updatedKeys.contains('movix_cloak_add') ||
            event.updatedKeys.contains('movix_country_cloak')) {
          SwitchManager.instance.excutePage();
        }
      } catch (e) {
        commonDebugPrint("Remote config: Failed to activate updated config: $e");
      }
    });
  }

  // 拉取并激活配置，返回是否拉取并解析成功
  void fetchAndActivateConfig() async {
    try {
      commonDebugPrint("Firebase: 拉取远端配置");
      remoteConfig.fetchAndActivate().then((updated) {
        if (updated) {
          debugPrint("Remote config updated.");
        } else {
          debugPrint("Remote config fetchAndActivate called, but no update.");
        }

        // 无论是否有更新，都尝试将 RemoteConfig 中的数据转换为 AdConfig 对象
        bool isSuccess = parseAndCacheConfig();

        if (isSuccess && _config != null) {
          commonDebugPrint("Remote config: Reloading all ads with updated config.");
          AdManager.instance.loadAd('level_h', _config!.levelH);
          AdManager.instance.loadAd('open', _config!.open);
          AdManager.instance.loadAd('behavior', _config!.behavior);
          AdManager.instance.loadAd('behavior2', _config!.behavior2);
          AdManager.instance.loadAd('NVhome', _config!.nvhome);
        }
      });
    } catch (e) {
      commonDebugPrint("Firebase: 拉取远端配置失败: $e");
    }
  }

  /// 解析并缓存广告配置
  bool parseAndCacheConfig() {
    // 获取 JSON 字符串形式的配置
    final configString = remoteConfig.getString('ad_json_and');
    if (configString.isNotEmpty) {
      try {
        // 将 JSON 字符串解析为 Map
        final Map<String, dynamic> configMap = jsonDecode(configString);
        // 将 Map 转换为你的 AdConfig 模型类
        _config = AdConfig.fromJson(configMap);

        // 成功解析后，保存最新的有效配置到本地 Storage，以便下次启动兜底
        Storage.saveAdRulesConfig(configString);

        commonDebugPrint("Remote config: Ad config parsed and cached: ${_config?.toJson()}");
        return true;
      } catch (e) {
        commonDebugPrint("Remote config: Error parsing ad config JSON: $e");
        // 解析失败时回退到默认配置
        _config = _getDefaultAdConfig();
        return true;
      }
    } else {
      commonDebugPrint("Remote config: Ad config string is empty.");
      // 如果没有获取到，使用默认配置
      _config = _getDefaultAdConfig();
      return true;
    }
  }

  AdConfig _getDefaultAdConfig() {
    try {
      final Map<String, dynamic> defaultMap = jsonDecode(_defaultAdRulesJson);
      return AdConfig.fromJson(defaultMap);
    } catch (e) {
      // 返回一个安全的默认值
      return AdConfig(
        showCount: 100,
        sameInterval: 15,
        differentInterval: 30,
        timeOut: 10,
        openivtime: 30,
        playPointTime: 600,
        open: [],
        behavior: [],
        nvhome: [],
        levelH: [],
        behavior2: [],
        playMiddle: [],
        pause: [],
      );
    }
  }

  /// 解析并缓存广告点击配置
  bool parseAndCacheAdClickConfig() {
    // 获取 JSON 字符串形式的配置
    final configString = remoteConfig.getString('clickbait');
    if (configString.isNotEmpty) {
      try {
        // 将 JSON 字符串解析为 Map
        final Map<String, dynamic> configMap = jsonDecode(configString);
        // 将 Map 转换为你的 AdConfig 模型类
        _adClickConfig = AdClickConfig.fromJson(configMap);

        // 成功解析后，保存最新的有效配置到本地 Storage，以便下次启动兜底
        Storage.saveAdClickConfig(configString);

        commonDebugPrint("Remote config: Ad click config parsed and cached: ${_config?.toJson()}");
        return true;
      } catch (e) {
        commonDebugPrint("Remote config: Error parsing ad click config JSON: $e");
        // 解析失败时回退到默认配置
        _adClickConfig = _getDefaultAdClickConfig();
        return true;
      }
    } else {
      commonDebugPrint("Remote config: Ad click config string is empty.");
      // 如果没有获取到，使用默认配置
      _adClickConfig = _getDefaultAdClickConfig();
      return true;
    }
  }

  AdClickConfig _getDefaultAdClickConfig() {
    try {
      final Map<String, dynamic> defaultMap = jsonDecode(_defaultAdClickJson);
      return AdClickConfig.fromJson(defaultMap);
    } catch (e) {
      // 返回一个安全的默认值
      return AdClickConfig(native: 0, fullscreenNative: 0);
    }
  }
}
