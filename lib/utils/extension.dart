import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

extension StringExtension on String? {
  bool isEmptyString() {
    return isEmpty(this);
  }

  bool isNotEmptyString() {
    return isNotEmpty(this);
  }

  static bool isEmpty(String? text) {
    if (text == null) {
      return true;
    }
    return text.isEmpty;
  }

  static bool isNotEmpty(String? text) {
    if (text == null) {
      return false;
    }
    return text.isNotEmpty;
  }

  String buildFileName() {
    if (isEmptyString()) return '';
    String fileNameWithExtension = path.basename(this!);
    return path.withoutExtension(fileNameWithExtension);
  }

  Size size({TextStyle? style, double minWidth = 0.0, double maxWidth = double.infinity}) {
    if (isEmpty(this)) {
      return Size.zero;
    }
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: this,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout(minWidth: minWidth, maxWidth: maxWidth);
    return painter.size;
  }
}
