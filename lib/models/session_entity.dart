import 'package:editvideo/config/network/model/base_entity.dart';

class SessionEntity extends BaseEntity {
  int? id;
  String? title;
  String? cover;

  SessionEntity({this.id, this.title, this.cover});

  @override
  SessionEntity.fromJson(dynamic json) {
    id = json['_id'];
    title = json['title'];
    cover = json['cover'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['cover'] = cover;
    return data;
  }
}
