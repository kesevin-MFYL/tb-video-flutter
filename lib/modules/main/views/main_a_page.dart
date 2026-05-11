import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/main/controllers/main_a_controller.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/custom_bottom_navigation_bar.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainAPage extends StatelessWidget {
  const MainAPage({super.key});

  BottomNavigationBarItem tabbarItem({String? label, String? assets, String? selectedAssets}) {
    return BottomNavigationBarItem(
      label: label,
      icon: assets == null ? SizedBox.shrink() : Image.asset(assets, width: 40.w, height: 40.w),
      activeIcon: selectedAssets == null ? null : Image.asset(selectedAssets, width: 40.w, height: 40.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyView(context);
  }

  _bodyView(BuildContext context) {
    return GetBuilder<MainAController>(
      init: MainAController(),
      builder: (controller) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: PageBase(
                hasAppBar: false,
                bottomNavigationBar: CustomBottomNavigationBar(
                  currentIndex: controller.currentIndex,
                  backgroundColor: Colors.transparent,
                  items: [
                    tabbarItem(label: 'Home', assets: Assets.commonHomeOff, selectedAssets: Assets.commonHomeOn),
                    tabbarItem(
                      label: 'Settings',
                      assets: Assets.commonSettingOff,
                      selectedAssets: Assets.commonSettingOn,
                    ),
                  ],
                  onTap: (index) => controller.tabChanged(index),
                ),
                child: Stack(
                  children: controller.tabBarPages.map((e) {
                    return Offstage(offstage: controller.currentIndex != controller.tabBarPages.indexOf(e), child: e);
                  }).toList(),
                ),
              ),
            ),
            Positioned(
              bottom: safeAreaBottomDistance(
                'Home'.size(style: CommonTextStyle.instance(12.sp, fontWeight: CommonFontWeight.bold)).height,
              ),
              child: CommonButton(
                minSize: 70.w,
                borderRadius: BorderRadius.zero,
                onPressed: controller.addVideo,
                child: Image.asset(Assets.commonHomeAdd, width: 70.w, height: 70.w),
              ),
            ),
          ],
        );
      },
    );
  }
}
