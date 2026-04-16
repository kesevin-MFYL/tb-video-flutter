import 'package:get_storage/get_storage.dart';

class Storage {
  static const _kToken = '_token_key';

  // 本地化存储，存APP内部
  static GetStorage? _getStorage;

  // runApp方法前调用
  static init() async {
    await GetStorage.init();
    _getStorage = GetStorage();
  }

  static Future<void> setToken(String? token) async {
    return _getStorage!.write(_kToken, token);
  }

  static String? getToken() {
    return _getStorage!.read<String?>(_kToken);
  }
}
