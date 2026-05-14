import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/config/network/model/list_response.dart';
import 'package:editvideo/models/home_section_entity.dart';

class HomeApi {
  static final homeSectionPath = '/OHfDJYeUc/dkGIsWNmP/XkMzLSTL';

  /// 封禁地址
  static Future<ApiResult<ListResponse<HomeSectionEntity>?, ApiError>> getHomeSection() async {
    return await HttpUtils.postRequest(
      homeSectionPath,
      construction: HomeSectionEntity.fromJson,
      decoder: ListResponse<HomeSectionEntity>.fromJson,
    );
  }
}