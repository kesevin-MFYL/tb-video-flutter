import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/manager/admob/app_lifecycle_reactor.dart';
import 'package:get/get.dart';

class MainBController extends BaseController {

  @override
  void handRegister() async {
    AppLifecycleReactor.instance.listenToAppStateChanges();
  }

  @override
  void fetchData() async {
    final result = await HomeApi.getHomeSection();
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      commonDebugPrint('1111111-------${listData![0].title}');
    }
  }
}
