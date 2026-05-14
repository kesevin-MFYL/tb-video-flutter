import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/config/network/model/base_response.dart';

class ListResponse<T extends BaseEntity> extends ApiResponse {
  @override
  int? code;
  @override
  String? msg;
  List<T>? data;

  ListResponse({this.code, this.msg});

  ListResponse.fromJson(dynamic json, T Function(dynamic) construction) {
    if (json is Map) {
      code = json['code'];
      msg = json['msg'];
      final dataMap = json['data'];
      if (isSuccess() && dataMap is List<dynamic>) {
        data = dataMap.map((element) => construction(element)).toList();
      }
    }
  }
}
