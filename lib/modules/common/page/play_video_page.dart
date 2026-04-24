import 'dart:io';
import 'dart:ui';

import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/modules/home/controllers/my_memory_controller.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:editvideo/widget/bottom_sheet/operation_bottom_sheet_view.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:editvideo/widget/page_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'video_view.dart';

class PlayVideoPage extends StatefulWidget {
  const PlayVideoPage({super.key, required this.memoryInfo});

  final MemoryInfo memoryInfo;

  @override
  State<PlayVideoPage> createState() => _PlayVideoPageState();

  static void playVideo({required MemoryInfo memoryInfo}) {
    Get.to(transition: Transition.noTransition, () => PlayVideoPage(memoryInfo: memoryInfo));
  }
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  late MemoryInfo _memoryInfo;
  final GlobalKey<VideoViewState> _videoKey = GlobalKey<VideoViewState>();

  DateTime? dateTime;

  /// 是否全屏
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    _memoryInfo = widget.memoryInfo;

    dateTime = _memoryInfo.videoTime != null ? DateTime.fromMillisecondsSinceEpoch(_memoryInfo.videoTime!) : null;
  }

  /// 切换全屏
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _toggleFullScreen();
          }
        },
        child: Scaffold(
          backgroundColor: CommonColors.color333333,
          body: SizedBox.expand(child: _buildVideoView()),
        ),
      );
    }

    return PageBase(
      title: 'Play',
      isTransparentAppBar: true,
      actions: _actionView(),
      child: Stack(
        children: [
          // 模糊背景
          _buildBackground(),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 212.h, color: CommonColors.color333333, child: _buildVideoView()),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(Assets.commonFieldTitle, width: 32.w, height: 32.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 7.h),
                                  child: CommonText.instance(
                                    _memoryInfo.title ?? '--',
                                    16.sp,
                                    fontWeight: CommonFontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 日期
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              Image.asset(Assets.commonFieldDate, width: 32.w, height: 32.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: CommonText.instance(
                                  dateTime != null
                                      ? "${dateTime!.month.toString().padLeft(2, '0')}.${dateTime!.day.toString().padLeft(2, '0')}.${dateTime!.year}"
                                      : '--',
                                  16.sp,
                                  color: CommonColors.white.withOpacity(0.5),
                                  fontWeight: CommonFontWeight.medium,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 人物
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(Assets.commonFieldPerson, width: 32.w, height: 32.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 7.h),
                                  child: CommonText.instance(
                                    _memoryInfo.person.isEmptyString() ? '--' : _memoryInfo.person ?? '',
                                    16.sp,
                                    color: CommonColors.white.withOpacity(0.5),
                                    fontWeight: CommonFontWeight.medium,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 描述
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(Assets.commonFieldMemo, width: 32.w, height: 32.w),
                                  SizedBox(width: 8.w),
                                  if (_memoryInfo.memo.isEmptyString())
                                    CommonText.instance(
                                      '--',
                                      16.sp,
                                      color: CommonColors.white.withOpacity(0.5),
                                      fontWeight: CommonFontWeight.medium,
                                    ),
                                ],
                              ),

                              if (_memoryInfo.memo.isNotEmptyString()) ...[
                                SizedBox(height: 8.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                  decoration: BoxDecoration(
                                    color: CommonColors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: CommonText.instance(
                                    _memoryInfo.memo!,
                                    16.sp,
                                    color: CommonColors.white.withOpacity(0.5),
                                    fontWeight: CommonFontWeight.medium,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        if (_memoryInfo.videoInfo!.thumbnailPath != null && _memoryInfo.videoInfo!.thumbnailPath!.isNotEmpty)
          Positioned.fill(
            child: Image.file(
              File(_memoryInfo.videoInfo!.thumbnailPath!),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: CommonColors.black.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoView() {
    return VideoView(
      key: _videoKey,
      videoUrl: _memoryInfo.videoInfo?.path ?? '',
      thumbPath: _memoryInfo.videoInfo?.thumbnailPath,
      title: _memoryInfo.title,
      isFullScreen: _isFullScreen,
      onToggleFullScreen: _toggleFullScreen,
    );
  }

  _actionView() {
    return CommonButton(
      minSize: 0,
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      onPressed: () {
        OperationBottomSheetView.show(
          editAction: () async {
            _videoKey.currentState?.pauseVideo();

            final result = await Get.toNamed(Routes.editVideo, arguments: {'memoryInfo': _memoryInfo});
            if (result != null && result is MemoryInfo) {
              setState(() {
                _memoryInfo = result;
                dateTime = _memoryInfo.videoTime != null
                    ? DateTime.fromMillisecondsSinceEpoch(_memoryInfo.videoTime!)
                    : null;
              });
            }
          },
          deleteAction: () async {
            await Storage.deleteSavedMemory(_memoryInfo.id ?? '');
            Get.find<MyMemoryController>().getDataFromLocal();
            Get.back();
          },
        );
      },
      child: Image.asset(Assets.commonOperationMore, width: 24.w, height: 24.w),
    );
  }
}
