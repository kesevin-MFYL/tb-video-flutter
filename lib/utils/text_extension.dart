import 'package:editvideo/config/color/colors.dart';
import 'package:flutter/material.dart';

extension CommonFontWeight on FontWeight {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}

extension CommonTextStyle on TextStyle {
  static TextStyle instance(
    double fontSize, {
    Color color = CommonColors.textColor,
    FontStyle? fontStyle,
    FontWeight fontWeight = CommonFontWeight.regular,
    TextDecoration? decoration,
    Color? decorationColor,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      decoration: decoration,
      decorationColor: decorationColor,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }
}

extension CommonText on Text {
  static Text instance(
    String text,
    double fontSize, {
    Color color = CommonColors.textColor,
    FontStyle? fontStyle,
    FontWeight fontWeight = CommonFontWeight.regular,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    double? height,
    double? letterSpacing,
    List<Shadow>? shadows,
    StrutStyle? strutStyle,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      strutStyle: strutStyle,
      style: CommonTextStyle.instance(
        fontSize,
        color: color,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        shadows: shadows,
      ),
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
