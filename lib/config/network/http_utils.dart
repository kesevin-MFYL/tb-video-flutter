import 'dart:async';
import 'package:dio/dio.dart';
import 'package:editvideo/config/log/logger.dart';
import 'package:editvideo/config/network/api/api_path.dart';
import 'package:editvideo/config/network/model/api_error.dart';
import 'package:editvideo/config/network/model/api_result.dart';
import 'package:editvideo/config/network/model/base_response.dart';

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
    String url,
    dynamic body, {
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
    _updateHeaders();

    commonDebugPrint(
      "Request start\nmethod: GET\nurl: ${(dio.options.baseUrl) + path}\nparameters: $query\nbody: $body\nheaders:${dio.options.headers}",
      needSplit: true,
    );

    try {
      final response = await dio.request(
        path,
        queryParameters: query,
        data: body,
        options: Options(method: method),
      );

      try {
        final deResponse = decoder(response.data, construction);
        if (deResponse.isSuccess()) {
          commonDebugPrint(
            "Response success\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $query\nbody: $body\nheaders:${dio.options.headers}\nresponse:${response.data}",
            needSplit: true,
          );
          return ApiResult.succss(deResponse);
        } else {
          final error = deResponse.error!;
          commonDebugPrint(
            "Response error\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $query\nbody: $body\nheaders:${dio.options.headers}\nerror:${error.toString()}",
            needSplit: true,
          );
          return ApiResult.failure(error, responseData: deResponse);
        }
      } catch (e, stackTrace) {
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
        "Response error\nmethod: $method\nurl: ${(dio.options.baseUrl) + path}\nparameters: $query\nbody: $body\nheaders:${dio.options.headers}\nerror:${error.toString()}",
        needSplit: true,
      );
      return ApiResult.failure(error);
    }
  }

  static void _updateHeaders() {
    dio.options.headers['TOKEN'] =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJlbHlzaW1hdGVkZXYiLCJjaGFubmVsIjoiVU5LTk9XTiIsImlkIjoxODU0NDY1MjM4NDEyMTgxNTA1LCJleHAiOjE3OTU4MzgzMTAsInRpbWVzdGFtcCI6MTc2NDMwMjMxMDAyM30.fwsXs5ZQhepT7oQyME8c1nysCbAHQB0gqyqUczWipBM';
  }
}
