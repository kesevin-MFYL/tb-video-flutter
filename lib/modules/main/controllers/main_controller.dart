import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/modules/home/views/home_page.dart';
import 'package:editvideo/modules/setting/views/setting_page.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';

class MainController extends BaseController {
  var currentIndex = 0;

  final tabBarPages = [const HomePage(), SettingPage()];

  @override
  void onInit() async {
    super.onInit();
    // final isFirstOpen = Storage.getFirstOpen();
    // if (!(isFirstOpen ?? false)) {
      // Storage.setFirstOpen(true);
    // }
  }

  void tabChanged(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      update();
    }
  }

  void addVideo() {
    Get.toNamed(Routes.editVideo);
  }
}
