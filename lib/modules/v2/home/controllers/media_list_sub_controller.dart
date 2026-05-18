import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';

class MediaListSubController extends BaseController {
  var multiStatusType = MultiStatusType.statusLoading;

  final refreshController = EasyRefreshController(controlFinishRefresh: true, controlFinishLoad: true);

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

  ///todo 跳转播放页面
  void toMediaPlayPage(MediaItemEntity mediaItemEntity) {}

  //todo 跳转搜索
  void toSearch() {}
}
