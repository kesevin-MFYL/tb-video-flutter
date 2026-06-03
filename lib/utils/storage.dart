import 'dart:convert';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/models/media_history_entity.dart';
import 'package:get_storage/get_storage.dart';

class Storage {
  static const _kFirstOpen = '_first_open_key';
  static const _kCanToB = '_can_to_b_key';
  static const _kSavedMemories = '_saved_memories_key';
  static const _kDraftMemories = '_draft_memories_key';
  static const _kAdRulesConfig = '_ad_rules_config_key';
  static const _kSessionId = '_session_id_key';
  static const _kSearchHistory = '_search_history_key';
  static const _kViewedMedia = '_viewed_media_key';

  // 本地化存储，存APP内部
  static GetStorage? _getStorage;

  // runApp方法前调用
  static init() async {
    await GetStorage.init();
    _getStorage = GetStorage();
  }

  static Future<void> setFirstOpen(bool? firstOpen) async {
    return _getStorage!.write(_kFirstOpen, firstOpen);
  }

  static bool? getFirstOpen() {
    return _getStorage!.read<bool?>(_kFirstOpen);
  }

  static Future<void> setCanToB(bool? canToB) async {
    return _getStorage!.write(_kCanToB, canToB);
  }

  static bool? getCanToB() {
    return _getStorage!.read<bool?>(_kCanToB);
  }

  // === 搜索历史 ===
  static Future<void> addSearchHistory(String keyword) async {
    List<String> list = getSearchHistory();
    list.remove(keyword);
    list.insert(0, keyword);
    if (list.length > 50) {
      list = list.sublist(0, 50);
    }
    await _getStorage!.write(_kSearchHistory, jsonEncode(list));
  }

  static Future<void> clearSearchHistory() async {
    await _getStorage!.remove(_kSearchHistory);
  }

  static List<String> getSearchHistory() {
    final str = _getStorage!.read<String?>(_kSearchHistory);
    if (str != null && str.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => e.toString()).toList();
    }
    return [];
  }

  // === 保存数据 ===
  static Future<void> addSavedMemory(MemoryInfo memory) async {
    List<MemoryInfo> list = getSavedMemories();
    // 检查是否已存在（按id），存在则更新，不存在则添加
    final index = list.indexWhere((e) => e.id == memory.id);
    if (index != -1) {
      list[index] = memory;
    } else {
      list.insert(0, memory);
    }
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kSavedMemories, jsonEncode(jsonList));
  }

  static Future<void> deleteSavedMemory(String id) async {
    List<MemoryInfo> list = getSavedMemories();
    list.removeWhere((e) => e.id == id);
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kSavedMemories, jsonEncode(jsonList));
  }

  static List<MemoryInfo> getSavedMemories() {
    final str = _getStorage!.read<String?>(_kSavedMemories);
    if (str != null && str.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => MemoryInfo.fromJson(e)).toList();
    }
    return [];
  }

  // === 草稿数据 ===
  static Future<void> addDraftMemory(MemoryInfo memory) async {
    List<MemoryInfo> list = getDraftMemories();
    // 草稿每次添加如果ID存在就更新，或者直接新增
    final index = list.indexWhere((e) => e.id == memory.id);
    if (index != -1) {
      list[index] = memory;
    } else {
      list.insert(0, memory);
    }
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kDraftMemories, jsonEncode(jsonList));
  }

  static Future<void> deleteDraftMemory(String id) async {
    List<MemoryInfo> list = getDraftMemories();
    list.removeWhere((e) => e.id == id);
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kDraftMemories, jsonEncode(jsonList));
  }

  static List<MemoryInfo> getDraftMemories() {
    final str = _getStorage!.read<String?>(_kDraftMemories);
    if (str != null && str.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => MemoryInfo.fromJson(e)).toList();
    }
    return [];
  }

  // === 广告规则配置 ===
  static Future<void> saveAdRulesConfig(String configJson) async {
    return _getStorage!.write(_kAdRulesConfig, configJson);
  }

  static String? getAdRulesConfig() {
    return _getStorage!.read<String?>(_kAdRulesConfig);
  }

  // === Session ID ===
  static Future<void> saveSessionId(String sessionId) async {
    return _getStorage!.write(_kSessionId, sessionId);
  }

  static String? getSessionId() {
    return _getStorage!.read<String?>(_kSessionId);
  }

  // === 看过的media列表 ===
  static Future<void> addViewedMedia(MediaHistoryEntity media) async {
    List<MediaHistoryEntity> list = getViewedMedia();
    final index = list.indexWhere((e) => e.id == media.id);
    if (index != -1) {
      list[index] = media;
      // 存在则更新，并放到第一个位置
      final item = list.removeAt(index);
      list.insert(0, item);
    } else {
      list.insert(0, media);
    }
    // 限制长度，比如最多存50条
    if (list.length > 100) {
      list = list.sublist(0, 100);
    }
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kViewedMedia, jsonEncode(jsonList));
  }

  static Future<void> deleteViewedMedia(List<MediaHistoryEntity> itemsToRemove) async {
    List<MediaHistoryEntity> list = getViewedMedia();
    list.removeWhere((e) => itemsToRemove.contains(e));
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kViewedMedia, jsonEncode(jsonList));
  }

  static Future<void> deleteViewedMediaById(int id) async {
    List<MediaHistoryEntity> list = getViewedMedia();
    list.removeWhere((e) => e.id == id);
    final jsonList = list.map((e) => e.toJson()).toList();
    await _getStorage!.write(_kViewedMedia, jsonEncode(jsonList));
  }

  static List<MediaHistoryEntity> getViewedMedia() {
    final str = _getStorage!.read<String?>(_kViewedMedia);
    if (str != null && str.isNotEmpty) {
      final List<dynamic> jsonList = jsonDecode(str);
      return jsonList.map((e) => MediaHistoryEntity.fromJson(e)).toList();
    }
    return [];
  }

  static MediaHistoryEntity? getViewedMediaById(int id) {
    final list = getViewedMedia();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
