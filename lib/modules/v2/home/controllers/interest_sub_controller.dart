import 'package:easy_refresh/easy_refresh.dart';
import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/interest_all_entity.dart';

class InterestSubController extends BaseController {
  final refreshController = EasyRefreshController(controlFinishRefresh: false, controlFinishLoad: false);

  late InterestAllEntity interestAllEntity;

  var mediaList = <MediaItemEntity>[];

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is InterestAllEntity) {
      interestAllEntity = arguments;
    }
  }

  @override
  void fetchData() async {
    mediaList = interestAllEntity.dataList ?? [];
    update();
  }

  ///todo 分类详情
  void toInterestDetail(MediaItemEntity mediaItemEntity) {}
}
