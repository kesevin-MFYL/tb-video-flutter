import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/admob/ad_manager.dart';
import 'package:editvideo/manager/admob/app_lifecycle_reactor.dart';
import 'package:editvideo/manager/switch_manager.dart';
import 'package:editvideo/modules/home/views/home_page.dart';
import 'package:editvideo/modules/setting/views/setting_page.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainAController extends BaseController {
  var currentIndex = 0;

  final tabBarPages = [const HomePage(), SettingPage()];

  Worker? _worker;

  @override
  void handRegister() async {
    AppLifecycleReactor.instance.listenToAppStateChanges();
    // final isFirstOpen = Storage.getFirstOpen();
    // if (!(isFirstOpen ?? false)) {
      // Storage.setFirstOpen(true);
    // }

    _worker = ever(SwitchManager.instance.canToB, (canToB) async {
      if (canToB) {
        await AppStateEventNotifier.stopListening();
        Get.offAllNamed(Routes.mainB);
      }
    });
  }

  void tabChanged(int index) {
    if (currentIndex != index) {
      currentIndex = index;

      if (currentIndex == 0) {
        AdManager.instance.showAdIfAvailable('behavior');
      }
      update();
    }
  }

  void addVideo() {
    AdManager.instance.showAdIfAvailable('behavior', onAdDismissed: () {
      Get.toNamed(Routes.editVideo);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _worker?.dispose();
  }
}
