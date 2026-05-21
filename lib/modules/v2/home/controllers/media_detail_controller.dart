import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/storage.dart';

class MediaDetailController extends BaseController {

  late MediaItemEntity mediaItemEntity;

  @override
  void handArguments(arguments) {
    if (arguments != null && arguments is MediaItemEntity) {
      mediaItemEntity = arguments;
    }
  }

  @override
  void fetchData() {
    mediaItemEntity.viewTime = DateTime.now().millisecondsSinceEpoch;
    Storage.addViewedMedia(mediaItemEntity);
  }
}
