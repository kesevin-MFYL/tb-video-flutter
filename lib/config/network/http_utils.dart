import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/api_path.dart';
import 'package:editvideo/config/network/api/common_api.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_response.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef ConstructionAction<B> = B Function(dynamic data);
typedef DecoderAction<T, B> = T Function(dynamic data, ConstructionAction<B> construction);

/// 全局 Dio 单例
class DioManager {
  static final DioManager instance = DioManager._internal();

  factory DioManager() => instance;

  DioManager._internal();

  Dio? _dio;

  Dio get dio => _dio ??= _initDio();

  /// init dio
  Dio _initDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiPath.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    //添加请求响应拦截器
    // dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       //添加language
    //       options.headers["TOKEN"] = '';
    //
    //       handler.next(options);
    //     },
    //     onResponse: (response, handler) {
    //       handler.next(response);
    //     },
    //   ),
    // );
    return dio;
  }

  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }
}

class HttpUtils {
  /// 统一使用全局 Dio 单例
  static Dio get dio => DioManager.instance.dio;

  /// getRequest
  static Future<ApiResult<T, ApiError>> getRequest<T extends ApiResponse, B>(
    String url, {
    Map<String, dynamic>? query,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
  }) async {
    return _request(url, method: "GET", query: query, decoder: decoder, construction: construction);
  }

  /// postRequest
  static Future<ApiResult<T, ApiError>> postRequest<T extends ApiResponse, B>(
    String url, {
    dynamic body,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
    bool? hideCatch,
  }) {
    return _request(url, method: "POST", body: body, decoder: decoder, construction: construction);
  }

  /// putRequest
  static Future<ApiResult<T, ApiError>> putRequest<T extends ApiResponse, B>(
    String url,
    dynamic body, {
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
  }) {
    return _request(url, method: "PUT", body: body, decoder: decoder, construction: construction);
  }

  /// deleteRequest
  static Future<ApiResult<T, ApiError>> deleteRequest<T extends ApiResponse, B>(
    String url, {
    Map<String, dynamic>? query,
    dynamic body,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
  }) async {
    return _request(url, method: "DELETE", query: query, body: body, decoder: decoder, construction: construction);
  }

  /// 核心请求 _request
  static Future<ApiResult<T, ApiError>> _request<T extends ApiResponse, B>(
    String path, {
    required String method,
    dynamic body,
    Map<String, dynamic>? query,
    required ConstructionAction<B> construction,
    required DecoderAction<T, B> decoder,
  }) async {
    // // 没有网络
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // // ignore: unrelated_type_equality_checks
    // if (connectivityResult == ConnectivityResult.none) {
    //   _onError(ExceptionHandle.net_error, '网络异常，请检查你的网络！', onError);
    //   return;
    // }

    // 更新headers
    await _updateHeaders();

    dynamic finalQuery = query;
    dynamic finalBody = body;
    bool shouldMapping = !CommonApi.noMappingPath.contains(path);

    if (shouldMapping) {
      await _loadEntityRules();
      finalQuery = _translateParams(query, _entityRules);
      finalBody = _translateParams(body, _entityRules);
    }

    commonDebugPrint(
      "Request start\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $finalQuery\nbody: $finalBody\nheaders:${dio.options.headers}",
      needSplit: true,
    );

    try {
      final response = await dio.request(
        path,
        queryParameters: finalQuery is Map<String, dynamic> ? finalQuery : finalQuery as Map<String, dynamic>?,
        data: finalBody,
        options: Options(method: method),
      );

      try {
        dynamic decryptedData = response.data;
        if (shouldMapping) {
          decryptedData = _decryptResponseData(response.data);
          commonDebugPrint('Response: _decryptResponseData---$decryptedData', needSplit: true);
        }
        
        final finalResponseData = shouldMapping ? _translateResponseParams(decryptedData, _reverseEntityRules) : decryptedData;
        final deResponse = decoder(finalResponseData, construction);
        if (deResponse.isSuccess()) {
          commonDebugPrint(
            "Response success\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $finalQuery\nbody: $finalBody\nheaders:${dio.options.headers}\nresponse:$finalResponseData",
            needSplit: true,
          );
          return ApiResult.succss(deResponse);
        } else {
          final error = deResponse.error!;
          commonDebugPrint(
            "Response error\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $finalQuery\nbody: $finalBody\nheaders:${dio.options.headers}\nerror:${error.toString()}",
            needSplit: true,
          );
          return ApiResult.failure(error, responseData: deResponse);
        }
      } catch (e, stackTrace) {
        commonDebugPrint(
          "Response success\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $finalQuery\nbody: $finalBody\nheaders:${dio.options.headers}\nresponse:${response.data}\nParsing response data exception: $e",
          needSplit: true,
        );
        return ApiResult.failure(ApiError('Parsing response data exception: $e', -1));
      }
    } on DioException catch (e, stackTrace) {
      // final statusCode = e.response?.statusCode ?? -1;
      // final data = e.response?.data;
      // final rawMsg = (data is Map && data['msg'] != null) ? data['msg'].toString() : "";
      // final resultCode = (data is Map && data['code'] != null) ? data['code'] : statusCode;
      // final msg = rawMsg.trim().isEmpty ? null : rawMsg.trim();
      //
      // if (e.type == DioExceptionType.badResponse) {
      //   return ApiResult.failure(ApiError(msg ?? defaultMessage, resultCode));
      // }
      //
      // return ApiResult.failure(ApiError(defaultMessage, -1));

      final error = ApiError.create(e);
      commonDebugPrint(
        "Response error\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $finalQuery\nbody: $finalBody\nheaders:${dio.options.headers}\nerror:${error.toString()}",
        needSplit: true,
      );
      return ApiResult.failure(error);
    }
  }

  static dynamic _decryptResponseData(dynamic data) {
    if (data is String) {
      try {
        // 1. 去掉头部9个字符
        String processed = data.length > 9 ? data.substring(9) : '';
        
        // 2. 大小写互换
        StringBuffer swapped = StringBuffer();
        for (int i = 0; i < processed.length; i++) {
          String char = processed[i];
          String lower = char.toLowerCase();
          String upper = char.toUpperCase();
          if (char == lower) {
            swapped.write(upper);
          } else {
            swapped.write(lower);
          }
        }
        
        // 3. base64解码
        String normalized = base64.normalize(swapped.toString());
        String decodedStr = utf8.decode(base64Decode(normalized));
        
        // 尝试解析为 JSON
        try {
          return jsonDecode(decodedStr);
        } catch (_) {
          return decodedStr;
        }
      } catch (e) {
        commonDebugPrint('Decrypt response data error: $e');
        return data;
      }
    }
    return data;
  }

  //todo
  static String _pkgName = 'com.movix.editvideo';
  static String _deviceId = '';
  static String _appVersion = '';
  static Map<String, dynamic>? _headerRules;
  static Map<String, dynamic>? _entityRules;
  static Map<String, String>? _reverseEntityRules;

  static Future<void> _loadHeaderRules() async {
    if (_headerRules == null) {
      try {
        final String jsonString = await rootBundle.loadString('assets/json/header_rules.json');
        _headerRules = jsonDecode(jsonString);
      } catch (e) {
        commonDebugPrint('Error loading header rules: $e');
        _headerRules = {};
      }
    }
  }
  
  static Future<void> _loadEntityRules() async {
    if (_entityRules == null) {
      try {
        final String jsonString = await rootBundle.loadString('assets/json/entity_rules.json');
        _entityRules = jsonDecode(jsonString);
        _reverseEntityRules = {};
        _entityRules?.forEach((key, value) {
          if (value is String) {
            _reverseEntityRules![value] = key;
          }
        });
      } catch (e) {
        commonDebugPrint('Error loading entity rules: $e');
        _entityRules = {};
        _reverseEntityRules = {};
      }
    }
  }

  static dynamic _translateParams(dynamic data, Map<String, dynamic>? rules) {
    if (rules == null || rules.isEmpty || data == null) return data;
    
    if (data is Map) {
      Map<String, dynamic> result = {};
      data.forEach((key, value) {
        String newKey = rules[key] ?? key;
        result[newKey] = _translateParams(value, rules);
      });
      return result;
    } else if (data is List) {
      return data.map((item) => _translateParams(item, rules)).toList();
    }
    return data;
  }

  static dynamic _translateResponseParams(dynamic data, Map<String, String>? reverseRules) {
    if (reverseRules == null || reverseRules.isEmpty || data == null) return data;

    if (data is Map) {
      Map<String, dynamic> result = {};
      data.forEach((key, value) {
        String newKey = reverseRules[key] ?? key;
        result[newKey] = _translateResponseParams(value, reverseRules);
      });
      return result;
    } else if (data is List) {
      return data.map((item) => _translateResponseParams(item, reverseRules)).toList();
    }
    return data;
  }

  static Future<void> _updateHeaders() async {
    if (_pkgName.isEmpty || _deviceId.isEmpty || _appVersion.isEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if (_pkgName.isEmpty) {
        _pkgName = packageInfo.packageName;
      }
      if (_deviceId.isEmpty) {
        try {
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          if (GetPlatform.isAndroid) {
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            _deviceId = androidInfo.id;
          } else if (GetPlatform.isIOS) {
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            _deviceId = iosInfo.identifierForVendor ?? '';
          }
        } catch (e) {
          commonDebugPrint('Error getting device id: $e');
        }
      }
      if (_appVersion.isEmpty) {
        _appVersion = packageInfo.version;
      }
    }

    await _loadHeaderRules();
    String pkgKey = _headerRules?['pkg'] ?? 'pkg';
    String devKey = _headerRules?['dev'] ?? 'dev';
    String verKey = _headerRules?['ver'] ?? 'ver';

    //包名
    dio.options.headers[pkgKey] = _pkgName;
    //设备id
    dio.options.headers[devKey] = _deviceId;
    //版本号
    dio.options.headers[verKey] = _appVersion;
  }
}
