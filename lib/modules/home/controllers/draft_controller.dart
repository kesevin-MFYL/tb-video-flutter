import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/native_ad_manager.dart';
import 'package:editvideo/manager/remote_config_manager.dart';
import 'package:editvideo/models/memory_info.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';

class DraftController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  /// draft列表
  var draftList = <MemoryInfo>[];

  @override
  void onInit() {
    super.onInit();
    _checkAndListenNVhomeAd();
    getDataFromLocal();
  }

  void getDataFromLocal() async {
    draftList = Storage.getDraftMemories();
    draftList.sort((a, b) => (b.operationTime ?? 0).compareTo(a.operationTime ?? 0));
    multiStatusType = draftList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    update();
  }

  void deleteDraft(MemoryInfo memoryInfo) async {
    await Storage.deleteDraftMemory(memoryInfo.id ?? '');
    getDataFromLocal();
  }

  void _checkAndListenNVhomeAd() {
    final scenario = 'NVhome';

    // 设置回调监听，无论是现在还在加载中，还是以后重新加载，只要成功/失败都会触发
    NativeAdManager.instance.setListener(
      scenario,
      onAdLoaded: (s) {
        update();
      },
      onAdFailed: (s, error) {
        // Future.delayed(const Duration(seconds: 3), () {
        //   _retryLoadAd(scenario);
        // });
      },
      onAdClosed: (s) {
        update();
      },
    );

    // 处理时间差问题：如果在进入该页面时，LaunchController 中的加载【已经】失败了，
    // 原生管理器里现在是没有广告的，也没有在加载中的状态，我们需要主动重试。
    // 但是 NativeAdManager 目前没有暴露 `isCurrentlyLoading` 状态，
    // 最安全的做法是：如果当前没加载好，我们就主动发一次加载请求。
    // 如果它内部其实已经加载好了，isAdLoaded 会返回 true，那么就不需要重新加载，只需 update() 渲染即可。
    if (NativeAdManager.instance.isAdLoaded(scenario)) {
      update();
    } else if (!NativeAdManager.instance.isAdLoading(scenario)) {
      // 当前不可用且没有在加载中，为了保险起见重新发起请求
      _retryLoadAd(scenario);
    } else {
      // 正在加载中，不做任何额外请求，等待 listener 触发回调即可
      commonDebugPrint('SettingController: $scenario ad is currently loading. Waiting for callback.');
    }
  }

  void _retryLoadAd(String scenario) {
    final config = RemoteConfigManager().config;
    if (config != null && config.nvhome.isNotEmpty) {
      AdManager.instance.loadAd(scenario, config.nvhome);
    }
  }

  @override
  void onClose() {
    // 离开页面时，如果不需要保留该原生广告缓存，可以销毁
    // 如果想要全局保留给其他页面复用，则不要在这里 dispose
    // NativeAdManager.instance.disposeAd('NVhome');
    super.onClose();
  }
}
