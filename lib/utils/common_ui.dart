import 'package:editvideo/config/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget loadingIndicator({Color? color, double? size, double strokeWidth = 5.5}) {
  return SizedBox(
    height: size ?? 50.w,
    width: size ?? 50.w,
    child: CircularProgressIndicator(
      backgroundColor: Colors.transparent,
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? CommonColors.primaryColor),
    ),
  );
}

