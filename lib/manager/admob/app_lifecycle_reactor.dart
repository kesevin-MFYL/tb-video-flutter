import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppLifecycleReactor {
  static final AppLifecycleReactor instance = AppLifecycleReactor._internal();
  factory AppLifecycleReactor() => instance;
  AppLifecycleReactor._internal();

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    commonDebugPrint('New AppState state: $appState');
    if (appState == AppState.foreground) {
      AdManager.instance.showAdIfAvailable('open', onAdDismissed: () {
        commonDebugPrint('app从后台切换回前台，关闭广告事件');
        EventBusManager.instance.post(EventBusName.playVideo);
      });
    }
  }
}
