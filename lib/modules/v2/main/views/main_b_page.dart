import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/main/controllers/main_b_controller.dart';
import 'package:editvideo/widget/custom_bottom_navigation_bar.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainBPage extends StatelessWidget {
  const MainBPage({super.key});

  BottomNavigationBarItem tabbarItem({String? label, String? assets, String? selectedAssets}) {
    return BottomNavigationBarItem(
      label: label,
      icon: assets == null ? SizedBox.shrink() : Image.asset(assets, width: 40.w, height: 40.w),
      activeIcon: selectedAssets == null ? null : Image.asset(selectedAssets, width: 40.w, height: 40.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainBController>(
      init: MainBController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: controller.currentIndex,
            backgroundColor: Colors.transparent,
            showMiddle: false,
            items: [
              tabbarItem(label: 'Home', assets: Assets.commonHomeOff, selectedAssets: Assets.commonHomeOn),
              tabbarItem(label: 'Explore', assets: Assets.commonExploreOff, selectedAssets: Assets.commonExploreOn),
              tabbarItem(label: 'History', assets: Assets.commonHistoryOff, selectedAssets: Assets.commonHistoryOn),
              tabbarItem(label: 'Settings', assets: Assets.commonSettingOff, selectedAssets: Assets.commonSettingOn),
            ],
            onTap: (index) => controller.tabChanged(index),
          ),
          child: Stack(
            children: controller.tabBarPages.map((e) {
              return Offstage(offstage: controller.currentIndex != controller.tabBarPages.indexOf(e), child: e);
            }).toList(),
          ),
        );
      },
    );
  }
}
