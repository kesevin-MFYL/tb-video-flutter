import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';

class LaunchController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(milliseconds: 800), () {
      Get.offAllNamed(Routes.main);
    });
  }
}