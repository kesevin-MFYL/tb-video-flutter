import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/main/controllers/main_b_controller.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/custom_bottom_navigation_bar.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (GetPlatform.isAndroid) {
          const MethodChannel('tbvideo/app_retain').invokeMethod('sendToBackground');
        }
      },
      child: GetBuilder<MainBController>(
        init: MainBController(),
        builder: (controller) {
        return Stack(
          children: [
            PageBase(
              hasAppBar: false,
              bottomNavigationBar: CustomBottomNavigationBar(
                currentIndex: controller.currentIndex,
                backgroundColor: Colors.transparent,
                showMiddle: false,
                items: [
                  tabbarItem(label: 'Home', assets: Assets.commonHomeOff, selectedAssets: Assets.commonHomeOn),
                  tabbarItem(label: 'Explore', assets: Assets.commonExploreOff, selectedAssets: Assets.commonExploreOn),
                  tabbarItem(label: 'History', assets: Assets.commonHistoryOff, selectedAssets: Assets.commonHistoryOn),
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

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Obx(() {
                final showDeletePopup = controller.showDeletePopup.value;
                final chooseCount = controller.chooseList.length;
                return IgnorePointer(
                  ignoring: !showDeletePopup,
                  child: ClipRect(
                    child: TweenAnimationBuilder<Offset>(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      tween: showDeletePopup
                          ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                          : Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)),
                      builder: (context, offset, child) {
                        return FractionalTranslation(translation: offset, child: child);
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: safeAreaEdgeInsets.bottom),
                        height: controller.getDeletePopupHeight,
                        decoration: BoxDecoration(
                          color: chooseCount > 0 ? CommonColors.primaryColor : CommonColors.color333333,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32.h),
                            topRight: Radius.circular(32.h),
                          ),
                        ),
                        child: Center(
                          child: CommonButton(
                            minSize: 0,
                            borderRadius: BorderRadius.zero,
                            onPressed: () {
                              if (chooseCount > 0) {
                                controller.deleteHistory();
                              }
                            },
                            child: ClipOval(
                              child: Container(
                                color: chooseCount > 0 ? CommonColors.colorD43364 : CommonColors.white.withOpacity(0.3),
                                alignment: Alignment.center,
                                width: 54.w,
                                height: 54.w,
                                child: Image.asset(chooseCount > 0 ? Assets.commonVideoDeleteWhite : Assets.commonVideoDeleteDisable, width: 32.w, height: 32.w),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    ));
  }
}
