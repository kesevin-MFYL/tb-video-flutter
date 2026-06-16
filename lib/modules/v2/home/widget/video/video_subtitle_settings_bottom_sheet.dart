import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/media/video_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 字幕设置内容视图(用于竖屏底部弹窗)
class VideoSubtitleSettingsBottomSheet extends StatefulWidget {
  final PlayerController controller;
  final VoidCallback onClose;
  final bool isOpen;

  const VideoSubtitleSettingsBottomSheet({super.key, required this.controller, required this.onClose, this.isOpen = false});

  @override
  State<VideoSubtitleSettingsBottomSheet> createState() => _VideoSubtitleSettingsBottomSheetState();
}

class _VideoSubtitleSettingsBottomSheetState extends State<VideoSubtitleSettingsBottomSheet> {
  final PageController _pageController = PageController(initialPage: 0, keepPage: false);
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(VideoSubtitleSettingsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      if (_pageController.hasClients && _pageController.page != 0) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    final list = widget.controller.captionList;
    final selected = widget.controller.selectedCaption.value;
    if (selected != null) {
      final index = list.indexOf(selected);
      if (index != -1) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_scrollController.hasClients) {
            final viewportDimension = _scrollController.position.viewportDimension;
            final itemHeight = 50.w;
            final spacing = 16.w;
            final padding = 16.w;
            final itemCenter = padding + index * (itemHeight + spacing) + itemHeight / 2;
            double offset = itemCenter - viewportDimension / 2;

            // Do not clamp to maxScrollExtent because ListView might not have laid out all items yet
            if (offset < 0) offset = 0;

            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [_buildMainMenu(), _buildLanguageList()],
    );
  }

  Widget _buildMainMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              CommonText.instance(
                'Subtitles',
                16.sp,
                color: CommonColors.white.withOpacity(0.8),
                fontWeight: CommonFontWeight.bold,
              ),
              Spacer(),
              CommonButton(
                minSize: 0,
                borderRadius: BorderRadius.zero,
                onPressed: widget.onClose,
                child: Image.asset(Assets.commonIconBottomClose, width: 24.w, height: 24.w),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.w),
        Obx(() {
          final openCaptions = widget.controller.openCaptions.value;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
            child: Row(
              children: [
                Image.asset(Assets.commonIconLabelSubtitle, width: 24.w, height: 24.w),
                SizedBox(width: 8.w),
                CommonText.instance(
                  openCaptions ? 'Turn Off Subtitles' : 'Turn On Subtitles',
                  14.sp,
                  fontWeight: CommonFontWeight.medium,
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.controller.setSubtitle(isOpen: !openCaptions);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40.w,
                    height: 24.w,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: openCaptions ? CommonColors.primaryColor : CommonColors.color333333,
                    ),
                    alignment: openCaptions ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: openCaptions ? CommonColors.color1B1B18 : CommonColors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
            _scrollToSelected();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
            child: Row(
              children: [
                Image.asset(Assets.commonIconLabelSubtitleLanguage, width: 24.w, height: 24.w),
                SizedBox(width: 8.w),
                CommonText.instance('Switch Language', 14.sp, fontWeight: CommonFontWeight.medium),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              CommonButton(
                minSize: 24.w,
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Image.asset(Assets.commonNavBack, width: 24.w, height: 24.w),
              ),
              SizedBox(width: 8.w),
              CommonText.instance(
                'Switch Language',
                16.sp,
                color: CommonColors.white.withOpacity(0.8),
                fontWeight: CommonFontWeight.bold,
              ),
              Spacer(),
              CommonButton(
                minSize: 0,
                borderRadius: BorderRadius.zero,
                onPressed: widget.onClose,
                child: Image.asset(Assets.commonIconBottomClose, width: 24.w, height: 24.w),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = widget.controller.captionList;
            final selected = widget.controller.selectedCaption.value;
            return ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
              itemCount: list.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.w),
              itemBuilder: (context, index) {
                final item = list[index];
                final isSelected = selected == item && widget.controller.openCaptions.value;
                return GestureDetector(
                  onTap: () {
                    widget.controller.setSubtitle(caption: item);
                    widget.onClose();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CommonColors.color1B1B18.withOpacity(0.5)
                          : CommonColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: isSelected ? Border.all(color: CommonColors.primaryColor, width: 1.5.w) : null,
                    ),
                    child: Row(
                      children: [
                        CommonText.instance(
                          '${index + 1}'.padLeft(2, '0'),
                          14.sp,
                          color: isSelected ? CommonColors.primaryColor : Colors.white,
                          fontWeight: CommonFontWeight.bold,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: CommonText.instance(
                            item.displayName ?? '',
                            14.sp,
                            color: isSelected ? CommonColors.primaryColor : Colors.white,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
