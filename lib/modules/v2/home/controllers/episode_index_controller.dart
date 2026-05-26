import 'package:editvideo/base/base_controller.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/home_api.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/widget/page_status/multi_status_view.dart';

class EpisodeIndexController extends BaseController {
  EpisodeIndexController({required this.seasonEntity});

  var multiStatusType = MultiStatusType.statusLoading;

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
      multiStatusType = episodeList.isEmpty ? MultiStatusType.statusEmpty : MultiStatusType.statusContent;
    } else {
      commonDebugPrint(result.error?.message ?? ApiResponse.unknownErrorMsg);
      multiStatusType = MultiStatusType.statusError;
    }
    update();
  }
}
