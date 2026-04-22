import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/web_controller.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final controller = Get.put(WebController());
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _progressChanged(0);
          },
          onProgress: _progressChanged,
          onPageFinished: (String url) {
            _progressChanged(100);
          },
        ),
      )
      ..loadRequest(Uri.parse(controller.webUrl));

    controller.webViewController = webViewController;
  }

  @override
  Widget build(BuildContext context) {
    return PageBase(
      title: controller.webType.title(),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3.0),
        child: Obx(
          () => controller.progress.value < 1.0
              ? LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: CommonColors.primaryColor,
                  value: controller.progress.value,
                )
              : const SizedBox.shrink(),
        ),
      ),
      child: WebViewWidget(controller: webViewController),
    );
  }

  void _progressChanged(int progress) {
    if (Get.isRegistered<WebController>()) {
      controller.progress.value = progress / 100;
    }
  }
}
