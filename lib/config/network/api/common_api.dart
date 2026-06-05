import 'package:dio/dio.dart';
import 'package:editvideo/config/network/http_utils.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:editvideo/models/ip_config_entity.dart';
import 'package:editvideo/utils/storage.dart';
import 'package:editvideo/widget/media/utils/string_utils.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum TbaParameterType {
  // 包名
  monument,
  // 操作系统，对应的{“away”: “android”, “botulin”: “ios”, “madam”: “web”, “rattle”: “macos”, “precinct”: “windows”}
  mcdonald,
  // 版本号
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

  static final cloakPath = 'https://terrier.movixweb.com/unix/inductee';
  static final ipAddressPath = '/TaaEbOP/VkcwZy/HgIshGoVv';

  static final submitViewVideoPath = 'https://api.graphql.imdb.com';

  // 不需要映射
  static final List<String> noMappingPath = [
    cloakPath,
    submitViewVideoPath,
  ];

  /// 是否黑名单
  static Future<ApiResult<BaseResponse<String?>?, ApiError>> cloak() async {
    String osType = '';
    if (GetPlatform.isAndroid) {
      osType = 'away';
    } else if (GetPlatform.isIOS) {
      osType = 'botulin';
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model = '';
    String osVersion = '';

    if (GetPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
      osVersion = androidInfo.version.release;
    } else if (GetPlatform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
    }

    ///todo 替换包名
    final Map<String, dynamic> body = {
      TbaParameterType.monument.name: 'com.movix.editvideo'/*packageInfo.packageName*/,
      TbaParameterType.mcdonald.name: osType,
      TbaParameterType.burmese.name: packageInfo.version,
      TbaParameterType.raman.name: DateTime.now().millisecondsSinceEpoch,
      TbaParameterType.agenda.name: model,
      TbaParameterType.bless.name: osVersion,
    };
    return await HttpUtils.postRequest(
      cloakPath,
      body: body,
      construction: (data) => data is String ? data : null,
      decoder: BaseResponse<String?>.fromJson,
    );
  }

  /// 封禁地址
  static Future<ApiResult<BaseResponse<IpConfigEntity>?, ApiError>> getIpAddress() async {
    return await HttpUtils.postRequest(
      ipAddressPath,
      construction: IpConfigEntity.fromJson,
      decoder: BaseResponse<IpConfigEntity>.fromJson,
    );
  }

  /// 提交已看过的影视到IMDB
  static Future<ApiResult<BaseResponse<VoidObject>?, ApiError>> submitViewVideo({required String imdbId}) async {
    String? sessionId = Storage.getSessionId();
    if (sessionId == null || sessionId.isEmpty) {
      sessionId = StringUtils.generateSessionId();
      await Storage.saveSessionId(sessionId);
    }

    return await HttpUtils.postRequest(
      submitViewVideoPath,
      body: {
        "query": "mutation RVI_TitleView(" r"$constId" ": ID!) {\n  addToRecentlyViewedItems(input: {item: " r"$constId" "}) {\n    dateAdded\n    id\n  }\n}",
        "operationName": "RVI_TitleView",
        "variables": {
          "constId": imdbId
        }
      },
      options: Options(headers: {'x-amzn-sessionid': sessionId}),
      construction: VoidObject.fromJson,
      decoder: (dynamic data, construction) {
        return BaseResponse<VoidObject>(code: 200, msg: 'success')
          ..data = construction(data['data'] ?? data);
      },
    );
  }

}
