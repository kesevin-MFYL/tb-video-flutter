import 'dart:math';

import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/config/network/model/list_response.dart';
import 'package:editvideo/models/episode_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/imdb_list_sub_entity.dart';
import 'package:editvideo/models/interest_all_entity.dart';
import 'package:editvideo/models/interest_detail_entity.dart';
import 'package:editvideo/models/media_detail_entity.dart';
import 'package:editvideo/models/media_filter_entity.dart';
import 'package:editvideo/models/season_entity.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/utils/storage.dart';

class HomeApi {
  static final searchMediaPath = '/NHOhEdapcW/pdhKdrLk';

  static final homeSectionPath = '/OHfDJYeUc/dkGIsWNmP/XkMzLSTL';
  static final homeTopPicksPath = '/rdVY/UyqKyY';
  static final imdbListSubDetailPath = '/HeXjjuHsiM/BBrKQVCZCK';
  static final interestAllPath = '/RvMBP/naoZHaxBK/alqJSasj';
  static final interestDetailPath = '/dcr/PEOugQGkU/cVIfJt';

  static final mediaFilterPath = '/RcfN/UPe/RFdlfVJD';

  static final mediaDetailPath = '/euYPPnFMAy/Pdr';
  static final mediaRecommendPath = '/DFTJEUpY/zuWvNHqf/cKf';
  static final tvAllSeasonPath = '/VXBTwAg/YgB';
  static final tvSeasonAllEpisodePath = '/SSxOkjA/DkEpWK';

  /// 获取首页数据
  static Future<ApiResult<ListResponse<HomeSectionEntity>?, ApiError>> getHomeSection() async {
    return await HttpUtils.postRequest(
      homeSectionPath,
      construction: HomeSectionEntity.fromJson,
      decoder: ListResponse<HomeSectionEntity>.fromJson,
    );
  }

  /// 获取top picks
  static Future<ApiResult<ListResponse<MediaItemEntity>?, ApiError>> getTopPicks() async {
    String? sessionId = Storage.getSessionId();
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = _generateSessionId();
      await Storage.saveSessionId(sessionId);
    }

    final Map<String, dynamic> body = {'imdb_session_id': sessionId};
    return await HttpUtils.postRequest(
      homeTopPicksPath,
      body: body,
      construction: MediaItemEntity.fromJson,
      decoder: ListResponse<MediaItemEntity>.fromJson,
    );
  }

  /// 获取合集详情
  static Future<ApiResult<BaseResponse<ImdbListSubEntity>?, ApiError>> getImdbListSubDetail({required int? id}) async {
    final Map<String, dynamic> body = {'_id': id};
    return await HttpUtils.postRequest(
      imdbListSubDetailPath,
      body: body,
      construction: ImdbListSubEntity.fromJson,
      decoder: BaseResponse<ImdbListSubEntity>.fromJson,
    );
  }

  static String _generateSessionId() {
    final random = Random();
    final int part1 = 100 + random.nextInt(900); // 3 digits: 100-999
    final int part2 = 1000000 + random.nextInt(9000000); // 7 digits: 1000000-9999999
    final int part3 = 1000000 + random.nextInt(9000000); // 7 digits: 1000000-9999999
    return '$part1-$part2-$part3';
  }

  /// 获取所有分类数据
  static Future<ApiResult<ListResponse<InterestAllEntity>?, ApiError>> getAllInterest() async {
    return await HttpUtils.postRequest(
      interestAllPath,
      construction: InterestAllEntity.fromJson,
      decoder: ListResponse<InterestAllEntity>.fromJson,
    );
  }

  /// 获取分类详情
  static Future<ApiResult<BaseResponse<InterestDetailEntity>?, ApiError>> getInterestDetail({required int? id}) async {
    final Map<String, dynamic> body = {'_id': id};
    return await HttpUtils.postRequest(
      interestDetailPath,
      body: body,
      construction: InterestDetailEntity.fromJson,
      decoder: BaseResponse<InterestDetailEntity>.fromJson,
    );
  }

  /// 搜索媒体资源
  static Future<ApiResult<ListResponse<MediaItemEntity>?, ApiError>> searchMedia({
    String? keyword,
    int? type,
    String? genre,
    String? year,
    String? countryCode,
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> body = {
      'external_source': 'imdb',
      'page_number': pageNum,
      'page_size': pageSize,
    };

    body.setIfNotNull(value: keyword, key: 'fuzzy_match');
    body.setIfNotNull(value: type, key: 'type');
    body.setIfNotNull(value: genre, key: 'genre');
    body.setIfNotNull(value: year, key: 'year');
    body.setIfNotNull(value: countryCode, key: 'country_code');

    return await HttpUtils.postRequest(
      searchMediaPath,
      body: body,
      construction: MediaItemEntity.fromJson,
      decoder: ListResponse<MediaItemEntity>.fromJson,
    );
  }

  /// 获取媒体筛选条件
  static Future<ApiResult<BaseResponse<MediaFilterEntity>?, ApiError>> getMediaFilter() async {
    return await HttpUtils.getRequest(
      mediaFilterPath,
      construction: MediaFilterEntity.fromJson,
      decoder: BaseResponse<MediaFilterEntity>.fromJson,
    );
  }

  /// 媒体详情
  static Future<ApiResult<BaseResponse<MediaDetailEntity>?, ApiError>> getMediaDetail({required int? id}) async {
    final Map<String, dynamic> body = {'_id': id};
    return await HttpUtils.postRequest(
      mediaDetailPath,
      body: body,
      construction: MediaDetailEntity.fromJson,
      decoder: BaseResponse<MediaDetailEntity>.fromJson,
    );
  }

  /// 媒体推荐
  static Future<ApiResult<ListResponse<HomeSectionEntity>?, ApiError>> getMediaRecommend({required int? id}) async {
    final Map<String, dynamic> body = {'_id': id};
    return await HttpUtils.postRequest(
      mediaRecommendPath,
      body: body,
      construction: HomeSectionEntity.fromJson,
      decoder: ListResponse<HomeSectionEntity>.fromJson,
    );
  }

  /// 获取所有季
  static Future<ApiResult<ListResponse<SeasonEntity>?, ApiError>> getAllSeasons({required int? id}) async {
    final Map<String, dynamic> body = {'tv_show_id': id};
    return await HttpUtils.postRequest(
      tvAllSeasonPath,
      body: body,
      construction: SeasonEntity.fromJson,
      decoder: ListResponse<SeasonEntity>.fromJson,
    );
  }

  /// 获取季所有集
  static Future<ApiResult<ListResponse<EpisodeEntity>?, ApiError>> getSeasonAllEpisodes({required int? id}) async {
    final Map<String, dynamic> body = {'tv_show_season_id': id};
    return await HttpUtils.postRequest(
      tvSeasonAllEpisodePath,
      body: body,
      construction: EpisodeEntity.fromJson,
      decoder: ListResponse<EpisodeEntity>.fromJson,
    );
  }
}
