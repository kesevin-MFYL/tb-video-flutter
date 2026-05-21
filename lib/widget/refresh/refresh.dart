import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonRefresh {
  static EasyRefresh instance({
    Key? key,
    required Widget child,
    bool hasMore = true,
    bool hasBefore = true,
    Axis? triggerAxis = Axis.vertical,
    FutureOr Function()? onRefresh,
    FutureOr Function()? onLoad,
    EasyRefreshController? controller,
    ScrollController? scrollController,
  }) {
    return EasyRefresh(
      key: key,
      header: hasBefore && onRefresh != null ? ClassicHeader() : null,
      onRefresh: hasBefore ? onRefresh : null,
      footer: /*hasMore && */ onLoad != null
          ? ClassicFooter()
          : null,
      onLoad: /*hasMore ? */ onLoad /* : null*/,
      triggerAxis: triggerAxis,
      controller: controller,
      scrollController: scrollController,
      child: child,
    );
  }
}
