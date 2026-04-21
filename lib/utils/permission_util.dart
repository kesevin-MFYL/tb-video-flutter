import 'package:device_info_plus/device_info_plus.dart';
import 'package:editvideo/widget/dialog/permission_setting_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// 统一的权限请求方法
  static Future<bool> requestPermission(
      List<Permission> permissions,
      String message,
      ) async {
    final permission = permissions[0];
    final status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    // 第一次拒绝，可以请求
    if (status.isDenied) {
      PermissionStatus status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
      if (status.isPermanentlyDenied || status.isDenied) {
        showPermissionDialog(message);
        return false;
      }
    }

    // 永久拒绝，需要跳转到设置
    if (status.isPermanentlyDenied) {
      showPermissionDialog(message);
      return false;
    }
    return false;
  }

  /// 显示权限提示对话框
  static void showPermissionDialog(String message) {
    Get.dialog(PermissionSettingDialog(message: message));
  }

  /// 视频权限
  static Future<bool> videos({String? message}) async {
    message ??= '"Unable to retrieve videos, please check permission settings"';
    if (GetPlatform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final permission = androidInfo.version.sdkInt < 33 ? Permission.storage : Permission.videos;
      return await requestPermission([permission], message);
    } else {
      // iOS 使用 photos 权限
      return await requestPermission([Permission.photos], message);
    }
  }
}