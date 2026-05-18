import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/utils/time_utils.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImdbListSubCell extends StatelessWidget {
  const ImdbListSubCell({super.key, required this.mediaItem, this.action});

  final MediaItemEntity mediaItem;
  final void Function(MediaItemEntity mediaItem)? action;

  @override
  Widget build(BuildContext context) {
    final yearTag = TimeUtils.getYear(mediaItem.pubDate);
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      onPressed: () => action?.call(mediaItem),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 142.w,
            margin: EdgeInsets.only(top: 32.w),
            padding: EdgeInsets.only(left: 131.w, right: 16.w, bottom: 10.w),
            decoration: BoxDecoration(
              color: CommonColors.color1B1B18,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: CommonColors.color222222, width: 1.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.instance(
                        mediaItem.title ?? '',
                        14.sp,
                        fontWeight: CommonFontWeight.bold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4.w, // 标签之间的水平间距
                  runSpacing: 4.h, // 标签之间的垂直间距
                  children: [
                    if (mediaItem.countryCodeList != null && mediaItem.countryCodeList!.isNotEmpty)
                      _buildTag(tagName: mediaItem.countryCodeList![0]),
                    if (yearTag.isNotEmpty) _buildTag(tagName: yearTag),
                    if (mediaItem.certification.isNotEmptyString()) _buildTag(tagName: mediaItem.certification!),
                  ],
                ),

                if (mediaItem.description.isNotEmptyString())
                  ...[
                    SizedBox(height: 10.w),
                    CommonText.instance(
                      mediaItem.description ?? '',
                      12.sp,
                      color: CommonColors.white.withOpacity(0.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
              ],
            ),
          ),

          Positioned(
            left: 10.w,
            top: 0,
            child: Container(
              width: 109.w,
              height: 164.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: CommonColors.color333333,
                border: Border.all(color: CommonColors.color222222, width: 1.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CommonImageView.normal(
                  imageUrl: mediaItem.cover,
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (context, url, error) {
                    return Center(
                      child: Image.asset(Assets.commonMediaPlaceholder, width: 40.w, height: 40.w, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildTag({required String tagName}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: CommonColors.color84705C.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: CommonText.instance(tagName, 10.sp, color: CommonColors.white.withOpacity(0.8)),
    );
  }
}
