import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/media/media_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 字幕弹窗(横屏)
class SubtitleSettingDialog extends StatefulWidget {
  final MediaPlayerController controller;

  const SubtitleSettingDialog({super.key, required this.controller});

  @override
  State<SubtitleSettingDialog> createState() => _SubtitleSettingDialogState();
}

class _SubtitleSettingDialogState extends State<SubtitleSettingDialog> {
  final PageController _pageController = PageController(initialPage: 0, keepPage: false);
  final ScrollController _scrollController = ScrollController();

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
            final itemHeight = 50.0;
            final spacing = 16.0;
            final padding = 16.0;
            final itemCenter = padding + index * (itemHeight + spacing) + itemHeight / 2;
            double offset = itemCenter - viewportDimension / 2;

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
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 343,
          margin: EdgeInsets.only(top: 16, bottom: 16, right: 16),
          decoration: BoxDecoration(
            color: CommonColors.color1B1B18.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
          ),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildMainMenu(), _buildLanguageList()],
          ),
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 22, right: 16, bottom: 16),
          child: Row(
            children: [
              CommonText.instance(
                'Subtitles',
                16,
                color: CommonColors.white.withOpacity(0.8),
                fontWeight: CommonFontWeight.bold,
              ),
              Spacer(),
              CommonButton(
                minSize: 0,
                borderRadius: BorderRadius.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Image.asset(Assets.commonIconBottomClose, width: 24, height: 24),
              ),
            ],
          ),
        ),
        Obx(() {
          final openCaptions = widget.controller.openCaptions.value;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Image.asset(Assets.commonIconLabelSubtitle, width: 24, height: 24),
                SizedBox(width: 8),
                CommonText.instance(
                  openCaptions ? 'Turn Off Subtitles' : 'Turn On Subtitles',
                  14,
                  fontWeight: CommonFontWeight.medium,
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.controller.setSubtitle(isOpen: !openCaptions);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 24,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: openCaptions ? CommonColors.primaryColor : CommonColors.color333333,
                    ),
                    alignment: openCaptions ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
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
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
            _scrollToSelected();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Image.asset(Assets.commonIconLabelSubtitleLanguage, width: 24, height: 24),
                SizedBox(width: 8),
                CommonText.instance('Switch Language', 14, fontWeight: CommonFontWeight.medium),
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
          padding: EdgeInsets.only(left: 16, top: 22, right: 16, bottom: 16),
          child: Row(
            children: [
              CommonButton(
                minSize: 24,
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Image.asset(Assets.commonNavBack, width: 24, height: 24),
              ),
              SizedBox(width: 8),
              CommonText.instance(
                'Switch Language',
                16,
                color: CommonColors.white.withOpacity(0.8),
                fontWeight: CommonFontWeight.bold,
              ),
              Spacer(),
              CommonButton(
                minSize: 0,
                borderRadius: BorderRadius.zero,
                onPressed: () => Navigator.of(context).pop(),
                child: Image.asset(Assets.commonIconBottomClose, width: 24, height: 24),
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: list.length,
              separatorBuilder: (context, index) => SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = list[index];
                final isSelected = selected == item && widget.controller.openCaptions.value;
                return GestureDetector(
                  onTap: () {
                    widget.controller.setSubtitle(caption: item);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CommonColors.color1B1B18.withOpacity(0.5)
                          : CommonColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? Border.all(color: CommonColors.primaryColor, width: 1.5) : null,
                    ),
                    child: Row(
                      children: [
                        CommonText.instance(
                          '${index + 1}'.padLeft(2, '0'),
                          14,
                          color: isSelected ? CommonColors.primaryColor : Colors.white,
                          fontWeight: CommonFontWeight.bold,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CommonText.instance(
                            item.displayName ?? '',
                            14,
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
