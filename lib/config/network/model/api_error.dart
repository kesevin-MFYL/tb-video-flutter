import 'package:dio/dio.dart';

const String defaultMessage = "系统开小差，请稍后再试！";

class ApiError implements Error {
  final String message;

  final int code;

  ApiError(this.message, this.code);

  /// 解析 DioException
  factory ApiError.create(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return ApiError("请求取消", 10001);
      case DioExceptionType.connectionTimeout:
        return ApiError("连接超时, 请稍后再试", 10002);
      case DioExceptionType.sendTimeout:
        return ApiError("请求超时, 请稍后再试", 10003 );
      case DioExceptionType.receiveTimeout:
        return ApiError("响应超时, 请稍后再试",10004);
      case DioExceptionType.connectionError:
        return ApiError("网络连接错误, 请检查网络", 10005);
      case DioExceptionType.unknown:
        return ApiError("未知错误: ${error.error?.toString()}", 10006);
      case DioExceptionType.badResponse:
        {
          try {
            final statusCode = error.response?.statusCode ?? -1;
            final data = error.response?.data;
            final rawMsg = (data is Map && data['msg'] != null) ? data['msg'].toString() : "";
            final resultCode = (data is Map && data['code'] != null) ? data['code'] : statusCode;
            final msg = rawMsg.trim().isEmpty ? null : rawMsg.trim();

            return ApiError(msg ?? defaultMessage, resultCode);
          } catch (_) {
            return ApiError(defaultMessage, 10007);
          }
        }
      default:
        return ApiError(error.error?.toString() ?? "未知错误", 10008);
    }
  }

  @override
  String toString() {
    return 'RequestError{message: $message, statusCode: $code}';
  }

  @override
  StackTrace? get stackTrace => null;
}
