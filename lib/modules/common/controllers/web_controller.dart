import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum WebViewType {
  /// 任意网页
  none,

  /// 用户协议
  userAgreement,

  /// 隐私政策
  privacyPolicy;

  String title() {
    switch (this) {
      case WebViewType.none:
        return '';
      case WebViewType.userAgreement:
        return 'Terms of Service';
      case WebViewType.privacyPolicy:
        return 'Privacy Policy';
    }
  }
}

class WebController extends GetxController {

  WebViewController? webViewController;

  late WebViewType webType;
  late String webUrl;

  final progress = Rx(0.0);

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      webType = arguments['webType'] ?? WebViewType.none;
      webUrl = arguments['webUrl'] ?? '';

      final protocolIdentifierRegex = RegExp(r'^((http|ftp|https):\/\/)', caseSensitive: false);
      if (!webUrl.startsWith(protocolIdentifierRegex)) {
        webUrl = 'https://$webUrl';
      }
    }
  }
}