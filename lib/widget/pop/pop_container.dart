import 'package:editvideo/widget/pop/custom_pop_route.dart';
import 'package:flutter/material.dart';

class PopContainer extends StatefulWidget with PopChild {
  PopContainer({super.key, required this.child, required this.topOffset, this.onDismiss});

  final _PopController controller = _PopController();
  final Widget child;
  final double topOffset;
  VoidCallback? onDismiss;

  @override
  State<PopContainer> createState() => _PopContainerState();

  @override
  dismiss() {
    controller.dismiss();
    onDismiss?.call();
  }
}

class _PopContainerState extends State<PopContainer> with SingleTickerProviderStateMixin {
  Animation<Offset>? _animation;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    widget.controller._bindState(this);
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(_controller!);
    _controller?.forward();
  }

  dismiss() {
    _controller?.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.only(top: widget.topOffset),
        child: ClipRect(
          child: SlideTransition(
            position: _animation!,
            child: GestureDetector(child: widget.child, onTap: () {}),
          ),
        ),
      ),
    );
  }
}

class _PopController {
  _PopContainerState? state;

  _bindState(_PopContainerState state) {
    this.state = state;
  }

  dismiss() {
    state?.dismiss();
  }
}
