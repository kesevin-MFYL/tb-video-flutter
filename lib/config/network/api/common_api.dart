import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/config/network/model/base_response.dart';

enum TbaParameterType {
  // 包名
  monument,
  // 操作系统，对应的{“away”: “android”, “botulin”: “ios”, “madam”: “web”, “rattle”: “macos”, “precinct”: “windows”}
  mcdonald,
  // 系统版本
  burmese,
  // 时间戳
  raman,
  // 手机型号
  agenda,
  // 操作系统版本号
  bless,
  // google广告id, 没有开启google广告服务的设备获取不到，但是必须要尝试获取，用于归因，原值，
  sullen,
  // android App需要有该字段，原值
  prod,
}

class CommonApi {
  static Future<ApiResult<BaseResponse<String?>?, ApiError>> cloak() async {
    final Map<String, dynamic> body = {
      TbaParameterType.monument.name: 'com.movix.editvideo',///todo
      TbaParameterType.mcdonald.name: 'away',///todo
      TbaParameterType.burmese.name: '1.0.1',///todo
      TbaParameterType.raman.name: DateTime.now().millisecondsSinceEpoch,
      TbaParameterType.agenda.name: '',///todo
      TbaParameterType.bless.name: '',///todo
    };
    return await HttpUtils.postRequest(
      'https://terrier.movixweb.com/unix/inductee',
      body,
      construction: (data) => data is String ? data : null,
      decoder: BaseResponse<String?>.fromJson,
    );
  }
}
