import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/image/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchMediaCell extends StatelessWidget {
  const SearchMediaCell({super.key, required this.mediaItem, this.action});

  final MediaItemEntity mediaItem;
  final void Function(MediaItemEntity mediaItem)? action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action?.call(mediaItem),
      child: Stack(
        children: [
          Container(
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
                width: 80.w,
                height: 120.w,
                errorWidget: (context, url, error) {
                  return Center(
                    child: Image.asset(Assets.commonMediaPlaceholder, width: 40.w, height: 40.w, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ),

          Positioned(
            left: 92.w,
            right: 0,
            top: 12.w,
            bottom: 12.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText.instance(
                  mediaItem.title ?? '',
                  14.sp,
                  fontWeight: CommonFontWeight.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (mediaItem.certification.isNotEmptyString()) _buildTag(tagName: mediaItem.certification!),

                if ((mediaItem.countryCodeList != null && mediaItem.countryCodeList!.isNotEmpty) || mediaItem.year.isNotEmptyString())
                  CommonText.instance(_getCountryYearText(), 12.sp, color: CommonColors.primaryColor.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildTag({required String tagName}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: CommonColors.color84705C.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CommonText.instance(tagName, 12.sp, color: CommonColors.white.withOpacity(0.8)),
    );
  }

  String _getCountryYearText() {
    final country = mediaItem.country ?? '';
    final year = mediaItem.year ?? '';

    if (country.isNotEmpty && year.isNotEmpty) {
      return '$country-$year';
    }
    return country.isNotEmpty ? country : year;
  }
}
