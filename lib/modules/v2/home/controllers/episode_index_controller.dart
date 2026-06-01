import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/modules/v2/home/controllers/media_detail_controller.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';
import 'package:get/get.dart';

class EpisodeIndexController extends BaseController {
  EpisodeIndexController({required this.seasonEntity, required this.mediaId});

  MediaDetailController get mediaDetailController => Get.find<MediaDetailController>(tag: '$mediaId');

  var multiStatusType = MultiStatusType.statusLoading;

  final int mediaId;

  /// 季
  final SeasonEntity seasonEntity;

  /// 集列表
  var episodeList = <EpisodeEntity>[];

  void reload() {
    multiStatusType = MultiStatusType.statusLoading;
    update();
    _getEpisodeList();
  }

  @override
  void fetchData() {
    _getEpisodeList();
  }

  /// 获取剧集列表
  void _getEpisodeList() async {
    final result = await HomeApi.getSeasonAllEpisodes(id: seasonEntity.id);
    if (result.isSuccess) {
      final listData = result.responseData?.data;
      episodeList = listData ?? [];

      final initialIndex = mediaDetailController.seasonList.indexWhere((element) => element.id == seasonEntity.id);
      if (mediaDetailController.mediaHistoryEntity == null) {
        // 没有缓存 默认第一季第一集
        if (initialIndex == 0 && episodeList.isNotEmpty) {
          mediaDetailController.selectEpisode.value = episodeList.first;
          mediaDetailController.changeTitle();
        }
      }

      multiStatusType = episodeList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
    update();
  }
}
