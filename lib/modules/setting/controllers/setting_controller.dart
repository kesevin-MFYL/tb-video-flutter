import 'package:editvideo/base/base_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingController extends BaseController {

  Future<void> feedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '379352157@qq.com',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        EasyLoading.showToast('Please send your suggestions to 379352157@qq.com');
      }
    } catch (e) {
      EasyLoading.showToast('Please send your suggestions to 379352157@qq.com');
    }
  }
}