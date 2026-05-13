import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/admob/app_lifecycle_reactor.dart';

class MainBController extends BaseController {

  @override
  void handRegister() async {
    AppLifecycleReactor.instance.listenToAppStateChanges();
  }
}
