import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 搜索框
class CommonSearchBar extends StatefulWidget {
  const CommonSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onClearAction,
    this.onSearchAction,
    this.onFocusChange,
    this.prefixWidget,
    this.suffixWidget,
  });

  final TextEditingController? controller;

  final FocusNode? focusNode;

  /// 内容变化
  final ValueChanged<String>? onChanged;

  /// 点击清空按钮
  final GestureTapCallback? onClearAction;

  /// 点击搜索按钮或者点击键盘（搜索）
  final ValueChanged<String?>? onSearchAction;

  final ValueChanged<bool>? onFocusChange;

  final Widget? prefixWidget;
  final Widget? suffixWidget;

  @override
  State<CommonSearchBar> createState() => _CommonSearchBarState();
}

class _CommonSearchBarState extends State<CommonSearchBar> {
  bool _showCleanButton = false;
  late final TextEditingController _controller = TextEditingController();
  TextEditingController get _getController => widget.controller ?? _controller;
  late final FocusNode _focusNode = FocusNode();
  FocusNode get _getFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    super.initState();
    _getController.addListener(() {
      String value = _getController.text;
      if (value.isNotEmpty && _showCleanButton == false) {
        setState(() {
          _showCleanButton = true;
        });
      } else if (value.isEmpty && _showCleanButton == true) {
        setState(() {
          _showCleanButton = false;
        });
      }
    });

    _getFocusNode.addListener(() {
      widget.onFocusChange?.call(_getFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  TextFormField _getTextFormField() {
    _showCleanButton = _getController.text.isNotEmpty;

    return TextFormField(
      controller: _getController,
      textInputAction: TextInputAction.search,
      autocorrect: true,
      enableSuggestions: true,
      autofocus: true,
      selectionControls: MaterialTextSelectionControls(),
      maxLines: 1,
      textCapitalization: TextCapitalization.sentences,
      focusNode: _getFocusNode,
      style: CommonTextStyle.instance(14.sp, fontWeight: CommonFontWeight.medium),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isCollapsed: true,
        border: InputBorder.none,
        hintText: 'Search...',
        hintStyle: CommonTextStyle.instance(
          14.sp,
          color: CommonColors.white.withOpacity(0.5),
          fontWeight: CommonFontWeight.medium,
        ),
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: _onSearch,
    );
  }

  _onSearch(String? text) {
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSearchAction?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          if (widget.prefixWidget != null) ...[widget.prefixWidget!, SizedBox(width: 8.w)],
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.h),
                border: Border.all(color: CommonColors.primaryColor, width: 1.w),
              ),
              child: Row(
                children: [
                  Expanded(child: _getTextFormField()),
                  SizedBox(width: 10.w),
                  if (_showCleanButton)
                    CommonButton(
                      padding: EdgeInsets.zero,
                      minSize: 16.w,
                      child: Image.asset(Assets.commonIconClear, width: 16.w, height: 16.w),
                      onPressed: () {
                        setState(() {
                          _getController.clear();
                          _showCleanButton = false;
                        });
                        widget.onClearAction?.call();
                      },
                    ),
                ],
              ),
            ),
          ),
          if (widget.suffixWidget != null) ...[SizedBox(width: 16.w), widget.suffixWidget!],
        ],
      ),
    );
  }
}
