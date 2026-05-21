import 'package:flutter/material.dart';

mixin PopChild implements Widget {
  dismiss();
}

class CustomPopRoute extends PopupRoute {
  final PopChild child;
  final Offset? offsetLT, offsetRB;
  final Duration duration;
  final bool? cancelable;
  final bool? outsideTouchCancelable;
  final bool? darkEnable;
  final List<RRect>? highlights;

  CustomPopRoute({
    required this.child,
    this.offsetLT,
    this.offsetRB,
    this.cancelable = false,
    this.outsideTouchCancelable = false,
    this.darkEnable = true,
    this.duration = const Duration(milliseconds: 300),
    this.highlights,
  });

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return _PopRouteWidget(
      offsetLT: offsetLT,
      offsetRB: offsetRB,
      duration: duration,
      cancelable: cancelable!,
      outsideTouchCancelable: outsideTouchCancelable!,
      darkEnable: darkEnable!,
      highlights: highlights,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => duration;

  static pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static setHighlights(BuildContext context, List<RRect> highlights) {
    _PopRouteWidgetState.of(context)?.highlights = highlights;
  }
}

class _PopRouteWidget extends StatefulWidget {
  const _PopRouteWidget({
    super.key,
    required this.child,
    this.offsetLT,
    this.offsetRB,
    this.duration,
    this.cancelable = false,
    this.outsideTouchCancelable = false,
    this.darkEnable = true,
    this.highlights,
  });

  final PopChild child;
  final Offset? offsetLT, offsetRB;
  final Duration? duration;
  final bool cancelable;
  final bool outsideTouchCancelable;
  final bool darkEnable;
  final List<RRect>? highlights;

  @override
  State<_PopRouteWidget> createState() => _PopRouteWidgetState();
}

class _PopRouteWidgetState extends State<_PopRouteWidget> with SingleTickerProviderStateMixin {
  Animation<double>? opacityAnim;
  AnimationController? alphaController;
  List<RRect> _highlights = [];

  @override
  void initState() {
    super.initState();
    _highlights = widget.highlights ?? [];
    alphaController = AnimationController(vsync: this, duration: widget.duration);
    opacityAnim = Tween<double>(begin: 0, end: 0.6).animate(alphaController!);
    alphaController?.forward();
  }

  static _PopRouteWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PopRouteWidgetState>();
  }

  dismiss() {
    alphaController?.reverse();
  }

  set highlights(List<RRect> value) {
    setState(() {
      _highlights = value;
    });
  }

  @override
  void dispose() {
    alphaController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: GestureDetector(
        onTap: () {
          if (widget.outsideTouchCancelable) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            widget.darkEnable
                ? AnimatedBuilder(
                    animation: alphaController!,
                    builder: (_, __) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: widget.offsetLT?.dx ?? 0,
                          top: widget.offsetLT?.dy ?? 0,
                          right: widget.offsetRB?.dx ?? 0,
                          bottom: widget.offsetRB?.dy ?? 0,
                        ),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(opacityAnim!.value), BlendMode.srcOut),
                          child: Stack(children: _buildDark()),
                        ),
                      );
                    },
                  )
                : Container(),
            widget.child,
          ],
        ),
      ),
      onWillPop: () async {
        if (widget.cancelable) {
          return true;
        }
        return false;
      },
    );
  }

  List<Widget> _buildDark() {
    List<Widget> widgets = [];
    widgets.add(Container(color: Colors.transparent));
    for (RRect highlight in _highlights) {
      widgets.add(
        Positioned(
          left: highlight.left,
          top: highlight.top,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: highlight.tlRadius,
                topRight: highlight.trRadius,
                bottomLeft: highlight.blRadius,
                bottomRight: highlight.brRadius,
              ),
            ),
            width: highlight.width,
            height: highlight.height,
          ),
        ),
      );
    }
    return widgets;
  }
}
