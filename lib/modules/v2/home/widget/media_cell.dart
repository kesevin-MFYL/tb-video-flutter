import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MediaCell extends StatelessWidget {
  const MediaCell({
    super.key,
    required this.mediaItem,
    this.action,
    this.itemWidth = 110,
    this.imageHeight = 165,
    this.marginRight = 12,
    this.buttonBorderRadius = 16,
    this.bgColor,
    this.containerPadding,
    this.showBorder = true,
    this.showListOverlay = false,
  });

  final MediaItemEntity mediaItem;
  final void Function(MediaItemEntity mediaItem)? action;
  final double itemWidth;
  final double imageHeight;
  final double marginRight;
  final double buttonBorderRadius;
  final Color? bgColor;
  final EdgeInsetsGeometry? containerPadding;
  final bool showBorder;
  final bool showListOverlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: marginRight),
      child: CommonButton(
        minSize: 0,
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        color: bgColor,
        onPressed: () => action?.call(mediaItem),
        child: Container(
          width: itemWidth,
          padding: containerPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            border: showBorder ? Border.all(color: CommonColors.color222222, width: 1.w) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: CommonColors.color333333,
                        border: Border.all(color: CommonColors.color222222, width: 1.w),
                      ),
                      child: CommonImageView.normal(
                        imageUrl: mediaItem.cover,
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    if (showListOverlay)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [CommonColors.color060600.withOpacity(0), CommonColors.color060600],
                            ),
                          ),
                          child: CommonButton(
                            minSize: 20.w,
                            alignment: Alignment.centerLeft,
                            borderRadius: BorderRadius.circular(10.r),
                            spacing: 4.w,
                            suffixDirectional: SuffixDirectional.left,
                            suffixWidget: Image.asset(Assets.commonIconVideoList, width: 16.w, height: 16.w),
                            child: CommonText.instance(
                              'List',
                              10.sp,
                              color: CommonColors.white.withOpacity(0.8),
                              fontWeight: CommonFontWeight.medium,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 12.w),
              CommonText.instance(
                mediaItem.title ?? '',
                12.sp,
                fontWeight: CommonFontWeight.medium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
