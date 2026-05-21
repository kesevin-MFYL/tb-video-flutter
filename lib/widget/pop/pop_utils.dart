import 'package:editvideo/widget/pop/custom_pop_route.dart';
import 'package:flutter/material.dart';

class PopUtils {
  static pop(BuildContext context) {
    CustomPopRoute.pop(context);
  }

  static show(
    BuildContext context,
    PopChild child, {
    Offset? offsetLT,
    Offset? offsetRB,
    bool cancelable = false,
    bool outsideTouchCancelable = true,
    bool darkEnable = true,
    Duration duration = const Duration(milliseconds: 300),
    List<RRect>? highlights,
  }) {
    Navigator.of(context)
        .push(
          CustomPopRoute(
            child: child,
            offsetLT: offsetLT,
            offsetRB: offsetRB,
            cancelable: cancelable,
            outsideTouchCancelable: outsideTouchCancelable,
            darkEnable: darkEnable,
            duration: duration,
            highlights: highlights,
          ),
        )
        .then((value) => child.dismiss());
  }

  ///Set popup highlight positions
  static setHighlights(BuildContext context, List<RRect> highlights) {
    CustomPopRoute.setHighlights(context, highlights);
  }
}
