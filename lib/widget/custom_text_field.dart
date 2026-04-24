import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/color/colors.dart';

class CustomTextField extends StatefulWidget {
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
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 16.w,
              top: widget.suffixIcon != null ? 19.h : 22.h,
              right: 16.w,
              bottom: widget.suffixIcon != null ? 19.h : 21.h,
            ),
            decoration: BoxDecoration(
              color: CommonColors.color333333,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: widget.isRequired ? CommonColors.primaryColor : Colors.transparent, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: widget.keyboardType,
                    readOnly: widget.readOnly,
                    maxLines: widget.maxLines,
                    enabled: !widget.readOnly,
                    style: CommonTextStyle.instance(16.sp, fontWeight: CommonFontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText,
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
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      if (widget.onTap != null) {
                        widget.onTap!();
                        return;
                      }
                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }
                    },
                    child: widget.suffixIcon!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.prefixIcon != null) Positioned(left: 10.w, top: -20.w, child: widget.prefixIcon!),
        ],
      ),
    );
  }
}
