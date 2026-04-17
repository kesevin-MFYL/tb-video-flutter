import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/color/colors.dart';

class CustomTextField extends StatelessWidget {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final TextEditingController? controller;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final int? maxLines;
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.controller,
    this.isRequired = false,
    this.onChanged,
    this.keyboardType,
    this.onTap,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.only(left: 16.w, top: suffixIcon != null ? 19.h : 22.h, right: 16.w, bottom: suffixIcon != null ? 19.h : 21.h),
            decoration: BoxDecoration(
              color: CommonColors.color333333,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: isRequired ? CommonColors.primaryColor : Colors.transparent, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    keyboardType: keyboardType,
                    readOnly: readOnly,
                    maxLines: maxLines,
                    style: CommonTextStyle.instance(16.sp, fontWeight: CommonFontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: CommonTextStyle.instance(
                        16.sp,
                        color: CommonColors.color666666,
                        fontWeight: CommonFontWeight.bold,
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    cursorColor: CommonColors.primaryColor,
                  ),
                ),
                if (suffixIcon != null) ...[const SizedBox(width: 12), suffixIcon!],
              ],
            ),
          ),
          if (prefixIcon != null) Positioned(left: 10.w, top: -20.w, child: prefixIcon!),
        ],
      ),
    );
  }
}
