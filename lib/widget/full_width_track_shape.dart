import 'package:flutter/material.dart';

class FullWidthTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0; // 获取轨道高度
    // 手动计算一个充满父容器宽度的矩形区域
    final Rect rect = Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - trackHeight) / 2, // 垂直居中
      parentBox.size.width,
      trackHeight,
    );
    return rect;
  }
}