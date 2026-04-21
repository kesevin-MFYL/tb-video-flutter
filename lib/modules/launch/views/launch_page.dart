import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/launch/controllers/launch_controller.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LaunchController>(
      init: LaunchController(),
      builder: (logic) {
        return PageBase(
          hasAppBar: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: safeAreaTopDistance(216.h), child: Image.asset(Assets.commonLaunchIcon)),
              Positioned(left: 0, right: 0, bottom: 0, child: Image.asset(Assets.commonLaunchBg)),
            ],
          ),
        );
      },
    );
  }
}
