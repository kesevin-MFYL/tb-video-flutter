import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 影片详情
class MediaDetailPage extends GetView<MediaDetailController> {
  const MediaDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaDetailController>(
      init: MediaDetailController(),
      builder: (controller) {
        return PageBase(child: Container());
      },
    );
  }
}
