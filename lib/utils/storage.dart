import 'dart:convert';
import 'package:editvideo/models/memory_info.dart';
import 'package:get_storage/get_storage.dart';

class Storage {
  static const _kFirstOpen = '_first_open_key';
  static const _kSavedMemories = '_saved_memories_key';
  static const _kDraftMemories = '_draft_memories_key';

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
}
