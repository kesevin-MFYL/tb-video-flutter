import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  NativeExampleState createState() => NativeExampleState();
}

class NativeExampleState extends State<TestPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Example'),
        ),
        body: Stack(
          children: [
            Container(),
            if (NativeAdManager.instance.isAdLoaded('NVhome') && NativeAdManager.instance.getNativeAd('NVhome') != null)
              SizedBox(
                width: Get.width,
                height: Get.height,
                child: AdWidget(ad: NativeAdManager.instance.getNativeAd('NVhome')!),
              ),
          ]
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}