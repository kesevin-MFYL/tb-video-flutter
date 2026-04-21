import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionSettingDialog extends StatelessWidget {
  const PermissionSettingDialog({super.key, required this.message, this.title, this.settingsType});

  final String? title;
  final String message;
  final AppSettingsType? settingsType;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title ?? 'Whoops!'),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          child: Text('Cancel', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Get.back();
          },
        ),
        CupertinoDialogAction(
          child: Text('Give access', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Get.back();
            AppSettings.openAppSettings(type: settingsType ?? AppSettingsType.settings);
          },
        ),
      ],
    );
  }
}
