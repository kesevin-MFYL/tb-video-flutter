import 'dart:math';

import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/config/network/model/list_response.dart';
import 'package:editvideo/models/home_section_entity.dart';
import 'package:editvideo/utils/storage.dart';

class HomeApi {
  static final homeSectionPath = '/OHfDJYeUc/dkGIsWNmP/XkMzLSTL';

  static final homeTopPicksPath = '/rdVY/UyqKyY';

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

    final Map<String, dynamic> body = {
      'imdb_session_id': sessionId,
    };
    return await HttpUtils.postRequest(
      homeTopPicksPath,
      body: body,
      construction: MediaItemEntity.fromJson,
      decoder: ListResponse<MediaItemEntity>.fromJson,
    );
  }

  static String _generateSessionId() {
    final random = Random();
    final int part1 = 100 + random.nextInt(900); // 3 digits: 100-999
    final int part2 = 1000000 + random.nextInt(9000000); // 7 digits: 1000000-9999999
    final int part3 = 1000000 + random.nextInt(9000000); // 7 digits: 1000000-9999999
    return '$part1-$part2-$part3';
  }
}