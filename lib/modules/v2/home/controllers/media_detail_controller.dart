import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/manager/event_manager.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/media_history_entity.dart';
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
    // Save history with new entity
    final historyEntity = MediaHistoryEntity(
      id: mediaItemEntity.id,
      title: mediaItemEntity.title,
      cover: mediaItemEntity.cover,
      type: mediaItemEntity.type,
      viewTime: DateTime.now().millisecondsSinceEpoch,
      totalDuration: 0, // Placeholder or set real value if available
      currentDuration: 0, // Placeholder or set real value if available
    );
    Storage.addViewedMedia(historyEntity);

    EventBusManager.instance.post(EventBusName.historyRefresh);
  }
}
