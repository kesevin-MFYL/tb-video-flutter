import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/common/controllers/search_controller.dart';
import 'package:editvideo/modules/common/widget/search_media_cell.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
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
                      controller: controller.textController,
                      prefixWidget: Obx(() {
                        final showSearchResult = controller.showSearchResult.value;
                        return showSearchResult
                            ? SizedBox()
                            : CommonButton(
                                minSize: 32.w,
                                onPressed: Get.back,
                                child: Image.asset(Assets.commonNavBack, width: 32.w, height: 32.w),
                              );
                      }),
                      suffixWidget: Obx(() {
                        final showSearchResult = controller.showSearchResult.value;
                        return GestureDetector(
                          onTap: () {
                            if (showSearchResult) {
                              controller.showSearchResult.value = false;
                            } else {
                              controller.toSearch();
                            }
                          },
                          child: showSearchResult
                              ? CommonText.instance('Cancel', 14.sp, fontWeight: CommonFontWeight.bold)
                              : Image.asset(Assets.commonIconSearch, width: 24.w, height: 24.w),
                        );
                      }),
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          controller.changeToHistory();
                        } else {
                          controller.getTriggerWords(value);
                        }
                      },
                      onClearAction: controller.changeToHistory,
                      onSearchAction: (value) {
                        controller.toSearch();
                      },
                    ),

                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Obx(() {
      final showTrigger = controller.showTrigger.value;
      final showSearchResult = controller.showSearchResult.value;

      return showSearchResult
          ? _buildSearchResult()
          : showTrigger
          ? _buildTriggerWords()
          : _buildHistoryList();
    });
  }

  Widget _buildHistoryList() {
    return Center(child: CommonText.instance('History', 20.sp));
  }

  Widget _buildTriggerWords() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.w),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(height: 16.w, color: Colors.transparent),
      itemCount: controller.triggerWordList.length,
      itemBuilder: (context, index) {
        final trigger = controller.triggerWordList[index];
        return SizedBox(
          height: 50,
          child: CommonText.instance(trigger, 16.sp),
        );
      },
    );
  }

  Widget _buildSearchResult() {
    return CommonRefresh.instance(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      hasMore: controller.hasMore,
      onLoad: controller.onLoadMore,
      child: MultiStatusView(
        currentStatus: controller.multiStatus,
        action: () {
          controller.multiStatus = MultiStatusType.statusLoading;
          controller.onRefresh();
        },
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.w),
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(height: 16.w, color: Colors.transparent),
          itemCount: controller.mediaList.length,
          itemBuilder: (context, index) {
            final mediaItem = controller.mediaList[index];
            return SearchMediaCell(mediaItem: mediaItem, action: (media) {});
          },
        ),
      ),
    );
  }
}
