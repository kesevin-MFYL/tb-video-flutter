import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/config/network/model/base_response.dart';

class CommonApi {

  static Future<ApiResult<BaseResponse<VoidObject>?, ApiError>> getUserInfo() async {
    return await HttpUtils.getRequest(
      '/v1/user',
      construction: VoidObject.fromJson,
      decoder: BaseResponse<VoidObject>.fromJson,
    );
  }
}