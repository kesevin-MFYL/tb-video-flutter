import 'dart:convert';
import 'package:editvideo/config/log/logger.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AdItem {
  final String adsource;
  final int adweight;
  final String adtype;
  final String placementid;

  AdItem({
    required this.adsource,
    required this.adweight,
    required this.adtype,
    required this.placementid,
  });

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
    return {
      'adsource': adsource,
      'adweight': adweight,
      'adtype': adtype,
      'placementid': placementid,
    };
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

  AdConfig({
    required this.showCount,
    required this.sameInterval,
    required this.differentInterval,
    required this.timeOut,
    required this.openivtime,
    required this.playPointTime,
    required this.open,
    required this.behavior,
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
    };
  }
}

class RemoteConfigManager {
  static final RemoteConfigManager _instance = RemoteConfigManager._internal();
  factory RemoteConfigManager() => _instance;
  RemoteConfigManager._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  AdConfig? _config;

  AdConfig? get config => _config;

  Future<void> initialize() async {
    // 配置 Remote Config 的设置
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      // 设置获取配置的超时时间为7秒
      fetchTimeout: const Duration(seconds: 7),
      // 【关键】开发阶段：建议设置较短的间隔以便调试，例如 0 秒
      // 【重要】生产环境：务必遵循最低更新间隔为 1 小时 (3600 秒) 的官方建议，以避免性能问题
      minimumFetchInterval: kDebugMode
          ? const Duration(seconds: 0)
          : const Duration(hours: 1),
    ));
  }

  // 拉取并激活配置，返回是否拉取并解析成功
  Future<bool> fetchAndActivateConfig() async {
    try {
      // 从 Firebase 服务端拉取最新配置
      bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        commonDebugPrint("Remote config updated.");
      } else {
        commonDebugPrint("Remote config fetchAndActivate called, but no update.");
      }
      
      // 无论是否有更新，都尝试将 RemoteConfig 中的数据转换为 AdConfig 对象
      return _parseAndCacheConfig();
    } catch (e) {
      commonDebugPrint("Remote config: Failed to fetch and activate remote config: $e");
      return false;
    }
  }

  bool _parseAndCacheConfig() {
    // 获取 JSON 字符串形式的配置
    final configString = _remoteConfig.getString('ad_rules');
    if (configString.isNotEmpty) {
      try {
        // 将 JSON 字符串解析为 Map
        final Map<String, dynamic> configMap = jsonDecode(configString);
        // 将 Map 转换为你的 AdConfig 模型类
        _config = AdConfig.fromJson(configMap);
        commonDebugPrint("Remote config: Ad config parsed and cached: ${_config?.toJson()}");
        return true;
      } catch (e) {
        commonDebugPrint("Remote config: Error parsing ad config JSON: $e");
        _config = null;
        return false;
      }
    } else {
      commonDebugPrint("Remote config: Ad config string is empty.");
      _config = null;
      return false;
    }
  }
}