import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/common/controllers/search_controller.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/search/common_search_bar.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchPage extends GetView<SearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchController>(
      init: SearchController(),
      builder: (controller) {
        return PageBase(
          hasAppBar: false,
          child: Stack(
            children: [
              Container(
                height: 128.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonIconSearchBg)),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonSearchBar(
                      prefixWidget: CommonButton(
                        minSize: 32.w,
                        onPressed: Get.back,
                        child: Image.asset(Assets.commonNavBack, width: 32.w, height: 32.w),
                      ),
                      suffixWidget: Image.asset(Assets.commonIconSearch, width: 24.w, height: 24.w),
                      onChanged: (value) {
                        print('1111--onChanged--$value');
                      },
                      onClearAction: () {
                        print('1111--onClearAction-');
                      },
                      onSearchAction: (value) {
                        print('1111--onSearchAction--$value');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
