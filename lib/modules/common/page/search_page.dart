import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/modules/common/controllers/search_controller.dart';
import 'package:editvideo/modules/common/widget/search_media_cell.dart';
import 'package:editvideo/utils/common_values.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:editvideo/widget/search/common_search_bar.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';

class SearchPage extends GetView<SearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchController>(
      init: SearchController(),
      builder: (controller) {
        return Obx(() {
          if (controller.isShowingNativeAd && controller.nativeAdScenario != null) {
            final nativeAd = NativeAdManager.instance.getNativeAd(controller.nativeAdScenario!);
            if (nativeAd != null) {
              return PopScope(
                canPop: false,
                child: Scaffold(
                  backgroundColor: CommonColors.color060600,
                  body: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: AdWidget(ad: nativeAd),
                  ),
                ),
              );
            }
          }

          return PopScope(
            canPop: controller.canExit.value,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                controller.handleBack();
              }
            },
            child: PageBase(
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
                          focusNode: controller.focusNode,
                          prefixWidget: Obx(() {
                            final showSearchResult = controller.showSearchResult.value;
                            return showSearchResult
                                ? const SizedBox()
                                : CommonButton(
                                    minSize: 32.w,
                                    onPressed: controller.handleBack,
                                    child: Image.asset(Assets.commonNavBack, width: 32.w, height: 32.w),
                                  );
                          }),
                          suffixWidget: Obx(() {
                            final showSearchResult = controller.showSearchResult.value;
                            return GestureDetector(
                              onTap: () {
                                if (showSearchResult) {
                                  controller.changeToHistory();
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
                              controller.getTriggerWords();
                            }
                          },
                          onClearAction: controller.changeToHistory,
                          onSearchAction: (value) {
                            controller.toSearch();
                          },
                          onFocusChange: (value) {
                            if (value && controller.showSearchResult.value) {
                              controller.changeToTrigger();
                            }
                          },
                        ),
                        Expanded(child: _buildContent()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
    return Obx(() {
      final historyList = controller.searchHistoryList;
      if (historyList.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText.instance(
                  'History',
                  16.sp,
                  color: CommonColors.primaryColor,
                  fontWeight: CommonFontWeight.bold,
                ),
                GestureDetector(
                  onTap: controller.showDeleteHistoryBottomSheet,
                  child: Image.asset(Assets.commonIconDeleteHistory, width: 24.w, height: 24.w),
                ),
              ],
            ),
            SizedBox(height: 16.w),
            LayoutBuilder(
              builder: (context, constraints) {
                return Obx(() {
                  return _buildHistoryWrap(constraints.maxWidth, historyList, controller.isHistoryExpanded.value, () {
                    controller.isHistoryExpanded.value = !controller.isHistoryExpanded.value;
                  });
                });
              },
            ),
          ],
        ),
      );
    });
  }

  int _getLines(List<double> widths, double maxWidth, double spacing) {
    if (widths.isEmpty) return 1;
    int lines = 1;
    double currentWidth = 0;
    for (double w in widths) {
      if (currentWidth == 0) {
        currentWidth = w;
      } else if (currentWidth + spacing + w > maxWidth) {
        lines++;
        currentWidth = w;
      } else {
        currentWidth += spacing + w;
      }
    }
    return lines;
  }

  Widget _buildHistoryWrap(double maxWidth, List<String> historyList, bool isExpanded, VoidCallback onToggle) {
    double spacing = 16.w;

    List<double> itemWidths = historyList.map((item) {
      double w = item.size(style: CommonTextStyle.instance(14.sp)).width + 24.w;
      return w > maxWidth ? maxWidth : w;
    }).toList();

    int totalLinesWithoutButton = _getLines(itemWidths, maxWidth, spacing);
    if (totalLinesWithoutButton <= 2) {
      return Wrap(
        spacing: spacing,
        runSpacing: 16.w,
        children: historyList.map((e) => _buildHistoryItem(e, maxWidth)).toList(),
      );
    }

    int targetMaxLines = isExpanded ? 5 : 2;
    List<String> visibleItems = [];

    // We determine visibility purely by counting lines of items without the button first
    int currentLines = 1;
    double currentWidth = 0;

    for (int i = 0; i < historyList.length; i++) {
      double w = itemWidths[i];
      if (currentWidth == 0) {
        currentWidth = w;
      } else if (currentWidth + spacing + w > maxWidth) {
        currentLines++;
        currentWidth = w;
      } else {
        currentWidth += spacing + w;
      }

      if (currentLines > targetMaxLines) {
        break;
      }
      visibleItems.add(historyList[i]);
    }

    List<Widget> widgets = visibleItems.map((item) => _buildHistoryItem(item, maxWidth)).toList();

    // 展开按钮
    widgets.add(
      GestureDetector(
        onTap: onToggle,
        child: Container(
          height: 32.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: CommonColors.color333333, borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotatedBox(
                quarterTurns: isExpanded ? 0 : 2,
                child: Image.asset(Assets.commonIconExpandUp, width: 24.w, height: 24.w),
              ),
            ],
          ),
        ),
      ),
    );

    return Wrap(spacing: spacing, runSpacing: 16.w, children: widgets);
  }

  Widget _buildHistoryItem(String text, double maxWidth) {
    return GestureDetector(
      onTap: () {
        controller.textController.text = text;
        controller.toSearch();
      },
      child: Container(
        height: 32.w,
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(color: CommonColors.color333333, borderRadius: BorderRadius.circular(16.r)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: CommonText.instance(
                text,
                14.sp,
                color: CommonColors.white.withOpacity(0.8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerWords() {
    final keyword = controller.textController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 20.w, right: 16.w, bottom: 16.w),
          child: CommonText.instance(
            'Search "$keyword"',
            16.sp,
            color: CommonColors.colorDB88E6,
            fontWeight: CommonFontWeight.bold,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Divider(height: 1.w, color: CommonColors.white.withOpacity(0.15)),
        ),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: controller.triggerWordList.length,
            itemBuilder: (context, index) {
              final trigger = controller.triggerWordList[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.textController.text = trigger;
                  controller.toSearch();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 22.w),
                  child: Row(
                    children: [
                      Image.asset(Assets.commonIconSubSearch, width: 16.w, height: 16.w),
                      SizedBox(width: 8.w),
                      Expanded(child: _buildHighlightedText(trigger, keyword)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResult() {
    return CommonRefresh.instance(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      hasBefore: controller.hasRefresh,
      hasMore: controller.hasMore,
      onLoad: controller.hasRefresh ? controller.onLoadMore : null,
      child: MultiStatusView(
        currentStatus: controller.multiStatus,
        emptyWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Assets.commonIconSearchEmpty, width: 150.w, height: 150.w),
            SizedBox(height: 16.h),
            CommonText.instance(
              'No results found. Try different keywords',
              14.sp,
              color: CommonColors.white.withOpacity(0.5),
              fontWeight: CommonFontWeight.semiBold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            final keyword = controller.textController.text;
            return SearchMediaCell(
              mediaItem: mediaItem,
              keyword: keyword,
              action: (item) {
                controller.toMediaDetailSinglePage(mediaId: item.id, mediaType: item.type);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String keyword) {
    if (keyword.isEmpty) {
      return CommonText.instance(text, 14.sp, color: CommonColors.white.withOpacity(0.5));
    }

    final pattern = RegExp(RegExp.escape(keyword), caseSensitive: false);
    final spans = <TextSpan>[];

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        spans.add(TextSpan(text: match.group(0), style: CommonTextStyle.instance(14.sp)));
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.add(
            TextSpan(
              text: nonMatch,
              style: CommonTextStyle.instance(14.sp, color: CommonColors.white.withOpacity(0.5)),
            ),
          );
        }
        return '';
      },
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
