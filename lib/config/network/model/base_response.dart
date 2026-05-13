import 'package:editvideo/config/network/model/api_error.dart';

abstract class ApiResponse {
  int? code;
  String? msg;

  String errorMsg() {
    return msg ?? unknownErrorMsg;
  }

  bool isSuccess() {
    return code != null && code == 200;
  }

  ApiError? get error {
    if (!isSuccess()) {
      return ApiError(
        errorMsg(),
        code ?? unknownErrorCode,
      );
    }
    return null;
  }

  static final unknownErrorMsg = '未知错误，请稍后再试';
  static const unknownErrorCode = -888;
}

class BaseResponse<T> extends ApiResponse {
  @override
  int? code;
  @override
  String? msg;
  T? data;

  BaseResponse({this.code, this.msg});

  BaseResponse.fromJson(dynamic json, T Function(dynamic) construction) {
    if (json is Map) {
      code = json['code'];
      msg = json['msg'];
      final dataMap = json['data'];
      if (isSuccess()) {
        data = construction(dataMap);
      }
    } else if (json is String) {
      code = 200;
      if (isSuccess()) {
        data = construction(json);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['msg'] = msg;
    return data;
  }
}