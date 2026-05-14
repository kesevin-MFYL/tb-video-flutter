import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/admob/app_lifecycle_reactor.dart';
import 'package:editvideo/modules/v1/setting/views/setting_page.dart';
import 'package:editvideo/modules/v2/explore/views/explore_page.dart';
import 'package:editvideo/modules/v2/history/views/history_page.dart';
import 'package:editvideo/modules/v2/home/views/home_b_page.dart';

class MainBController extends BaseController {
  var currentIndex = 0;

  final tabBarPages = [const HomeBPage(), const ExplorePage(), const HistoryPage(), const SettingPage()];

  @override
  void handRegister() async {
    AppLifecycleReactor.instance.listenToAppStateChanges();
  }

  void tabChanged(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      update();
    }
  }
}
