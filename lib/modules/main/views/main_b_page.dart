import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/main/controllers/main_a_controller.dart';
import 'package:editvideo/modules/main/controllers/main_b_controller.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/custom_bottom_navigation_bar.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainBPage extends StatelessWidget {
  const MainBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainBController>(
      init: MainBController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: Container(
            color: Colors.red,
            child: Center(
              child: CommonText.instance('B面', 20.sp),
            ),
          ),
        );
      },
    );
  }
}
