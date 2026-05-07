import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/modules/home/controllers/draft_controller.dart';
import 'package:editvideo/modules/home/widget/video_cell.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:editvideo/widget/refresh/refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({super.key});

  @override
  State<DraftPage> createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<DraftController>(
      init: DraftController(),
      builder: (controller) {
        return VisibilityDetector(
          key: const Key('draftPage'),
          onVisibilityChanged: (info) async {
            if (info.visibleFraction > 0.0) {
              controller.loadNVhomeAd();
            }
          },
          child: Column(
              children: [
                Expanded(
                  child: CommonRefresh.instance(
                    hasBefore: false,
                    hasMore: false,
                    child: MultiStatusView(
                      hasAppBar: false,
                      currentStatus: controller.multiStatusType,
                      child: GridView.builder(
                        padding: EdgeInsets.only(left: 8.w, top: 12.h, right: 8.w, bottom: NativeAdManager.instance.isAdLoaded('NVhome') && NativeAdManager.instance.getNativeAd('NVhome') != null ? 12.h : 50.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.w,
                          mainAxisSpacing: 15.w,
                          childAspectRatio: 164 / 150,
                        ),
                        itemCount: controller.draftList.length,
                        itemBuilder: (context, index) {
                          final memoryInfo = controller.draftList[index];
                          return VideoCell(
                            memoryInfo: memoryInfo,
                            cellType: VideoCellType.draft,
                            videoAction: (memoryInfo, cellType) {
                              Get.toNamed(Routes.editVideo, arguments: {'memoryInfo': memoryInfo, 'isFromDraft': true});
                            },
                            operationAction: (memoryInfo, cellType) {
                              controller.deleteDraft(memoryInfo);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // 原生广告展示区域
                if (NativeAdManager.instance.isAdLoaded('NVhome') && NativeAdManager.instance.getNativeAd('NVhome') != null)
                  Container(
                    width: 300,
                    height: 250,
                    margin: EdgeInsets.only(top: 12.h, bottom: 30.h),
                    decoration: BoxDecoration(
                      color: CommonColors.color333333,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AdWidget(ad: NativeAdManager.instance.getNativeAd('NVhome')!),
                  ),
              ]
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
