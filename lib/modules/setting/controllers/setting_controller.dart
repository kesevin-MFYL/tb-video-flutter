import 'package:editvideo/base/base_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingController extends BaseController {

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