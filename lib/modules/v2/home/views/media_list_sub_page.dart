import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/v2/home/controllers/media_list_sub_controller.dart';
import 'package:editvideo/modules/v2/home/widget/media_cell.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 单片二级页面
class MediaListSubPage extends GetView<MediaListSubController> {
  const MediaListSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ratio = _getRatio();
    return GetBuilder<MediaListSubController>(
      init: MediaListSubController(),
      builder: (controller) {
        return PageBase(
          isTransparentAppBar: true,
          title: 'Trending',
          actions: _actionView(),
          child: Stack(
            children: [
              Container(
                height: 96.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: AssetImage(Assets.commonIconSubTitleBg)),
                ),
              ),
              SafeArea(
                child: CommonRefresh.instance(
                  controller: controller.refreshController,
                  hasBefore: false,
                  hasMore: false,
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 16.w,
                      childAspectRatio: ratio,
                    ),
                    itemCount: controller.mediaList.length,
                    itemBuilder: (context, index) {
                      var mediaItem = controller.mediaList[index];
                      return MediaCell(
                        mediaItem: mediaItem,
                        itemWidth: double.infinity,
                        imageHeight: 165.w,
                        action: (mediaItem) => controller.toMediaDetail(mediaItem),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _actionView() {
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      onPressed: controller.toSearch,
      child: Image.asset(Assets.commonIconSubSearch, width: 24.w, height: 24.w),
    );
  }

  double _getRatio() {
    final height =
        164 +
        8 +
        2 +
        'The Hobbit'.size(style: CommonTextStyle.instance(13.sp, fontWeight: CommonFontWeight.medium)).height;
    return 109 / height;
  }
}
