import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/consent_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingController extends BaseController {

  bool isPrivacyOptionsRequired = false;

  @override
  void onInit() {
    super.onInit();
    _checkPrivacyOptionsRequired();
  }

  void _checkPrivacyOptionsRequired() async {
    isPrivacyOptionsRequired = await ConsentManager.instance.isPrivacyOptionsRequired();
    update();
  }

  void showPrivacyOptions() {
    ConsentManager.instance.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        commonDebugPrint('SettingController: Failed to show privacy options form: ${formError.message}');
      }
      // 重新检查是否还需要显示隐私选项（比如用户改变了主意或删除了所有数据）
      _checkPrivacyOptionsRequired();
    });
  }

  Future<void> feedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'internationalscopesofficial@gmail.com',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        EasyLoading.showToast('Please send your suggestions to internationalscopesofficial@gmail.com');
      }
    } catch (e) {
      EasyLoading.showToast('Please send your suggestions to internationalscopesofficial@gmail.com');
    }
  }
}