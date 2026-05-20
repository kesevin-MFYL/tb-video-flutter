import 'dart:math';

import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/config/network/model/list_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/models/imdb_list_sub_entity.dart';
import 'package:editvideo/models/interest_all_entity.dart';
import 'package:editvideo/models/interest_detail_entity.dart';
import 'package:editvideo/utils/storage.dart';

class HomeApi {
  static final searchMediaPath = '/NHOhEdapcW/pdhKdrLk';

  static final homeSectionPath = '/OHfDJYeUc/dkGIsWNmP/XkMzLSTL';
  static final homeTopPicksPath = '/rdVY/UyqKyY';
  static final imdbListSubDetailPath = '/HeXjjuHsiM/BBrKQVCZCK';
  static final interestAllPath = '/RvMBP/naoZHaxBK/alqJSasj';
  static final interestDetailPath = '/dcr/PEOugQGkU/cVIfJt';

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

  static Future<ApiResult<ListResponse<MediaItemEntity>?, ApiError>> searchMedia({
    required String keyword,
    required int pageNum,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> body = {
      'fuzzy_match': keyword,
      'external_source': 'imdb',
      'page_number': pageNum,
      'page_size': pageSize,
    };
    return await HttpUtils.postRequest(
      searchMediaPath,
      body: body,
      construction: MediaItemEntity.fromJson,
      decoder: ListResponse<MediaItemEntity>.fromJson,
    );
  }
}
