import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/mixin/media_operate_mixin.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/routes/app_routes.dart';
import 'package:get/get.dart';

class MediaListSubController extends BaseController with MediaOperateMixin {
  final refreshController = EasyRefreshController(controlFinishRefresh: false, controlFinishLoad: false);

  late HomeSectionEntity homeSectionEntity;

  var mediaList = <MediaItemEntity>[];

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is HomeSectionEntity) {
      homeSectionEntity = arguments;
    }
  }

  @override
  void fetchData() async {
    mediaList = homeSectionEntity.dataList ?? [];
    update();
  }

  ///跳转搜索
  void toSearch() {
    Get.toNamed(Routes.searchPage);
  }
}
