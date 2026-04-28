import 'dart:io';

void main(List<String> args) {
  try {
    _replaceFirebaseConfig();
    print('✅ Firebase 配置替换完成！');
  } catch (e) {
    print('❌ 替换失败: $e');
    exit(1);
  }
}

/// 根据参数执行 Firebase 配置替换
void _replaceFirebaseConfig() {
  _replaceFirebaseOptionsConfig();
  _replaceFirebaseJsonConfig();
  _replaceAndroidFirebaseConfig();
}

void _replaceFirebaseOptionsConfig() {
  final sourceFile = File('manifest/prod/firebase_options.dart');
  final targetFile = File('lib/firebase_options.dart');
  if (!sourceFile.existsSync()) {
    throw 'Firebase 配置文件不存在: ${sourceFile.path}';
  }
  final content = sourceFile.readAsStringSync();
  targetFile.writeAsStringSync(content);
  print('   ✓ FirebaseOptions 配置文件替换完成');
}

void _replaceFirebaseJsonConfig() {
  final sourceFile = File('manifest/prod/firebase.json');
  final targetFile = File('firebase.json');

  if (!sourceFile.existsSync()) {
    throw 'Firebase 配置文件不存在: ${sourceFile.path}';
  }

  final content = sourceFile.readAsStringSync();
  targetFile.writeAsStringSync(content);
  print('   ✓ FirebaseJson 配置文件替换完成');
}

/// 替换 Android Firebase 配置
void _replaceAndroidFirebaseConfig() {
  final sourceFile = File('manifest/prod/google-services.json');
  final targetFile = File('android/app/google-services.json');

  if (!sourceFile.existsSync()) {
    throw 'Android Firebase 配置文件不存在: ${sourceFile.path}';
  }

  final content = sourceFile.readAsStringSync();
  targetFile.writeAsStringSync(content);
  print('   ✓ Android google-services.json (from prod) 替换完成');
}
