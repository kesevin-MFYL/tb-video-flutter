import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/home/controllers/home_b_controller.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeBPage extends StatelessWidget {
  const HomeBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeBController>(
      init: HomeBController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: Stack(
            children: [
              Container(
                height: 110.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonHomeBg)),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
