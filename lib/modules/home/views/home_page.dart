import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/home/controllers/home_controller.dart';
import 'package:editvideo/modules/home/views/draft_page.dart';
import 'package:editvideo/modules/home/views/my_memory_page.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
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
                    Padding(
                      padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 10.h),
                      child: Row(
                        spacing: 32.w,
                        children: [
                          // my memory
                          Obx(() {
                            final queryType = controller.queryType.value;
                            return GestureDetector(
                              onTap: () => controller.queryChanged(QueryType.myMemory),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    queryType == QueryType.myMemory ? Assets.commonMemoryOn : Assets.commonMemoryOff,
                                    width: queryType == QueryType.myMemory ? 143.w : 119.w,
                                    height: queryType == QueryType.myMemory ? 48.w : 40.w,
                                  ),
                                  queryType == QueryType.myMemory
                                      ? Positioned(
                                          left: 0,
                                          bottom: 0,
                                          child: Image.asset(Assets.commonTabSelected, width: 93.w, height: 18.w),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            );
                          }),

                          // draft
                          Obx(() {
                            final queryType = controller.queryType.value;
                            return GestureDetector(
                              onTap: () => controller.queryChanged(QueryType.draft),
                              child: SizedBox(
                                width: queryType == QueryType.draft ? 93.w : null,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      queryType == QueryType.draft ? Assets.commonDraftOn : Assets.commonDraftOff,
                                      width: queryType == QueryType.draft ? 59.w : 49.w,
                                      height: queryType == QueryType.draft ? 48.w : 40.w,
                                    ),
                                    queryType == QueryType.draft
                                        ? Positioned(
                                            left: 0,
                                            bottom: 0,
                                            child: Image.asset(Assets.commonTabSelected, width: 93.w, height: 18.w),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return MyMemoryPage();
                            case 1:
                              return DraftPage();
                            default:
                              return null;
                          }
                        },
                      ),
                    ),
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
