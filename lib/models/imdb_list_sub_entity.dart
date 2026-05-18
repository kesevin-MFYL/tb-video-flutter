import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';

class ImdbListSubEntity extends BaseEntity {
  int? id;
  String? title;
  String? cover;
  List<MediaItemEntity>? dataList;

  ImdbListSubEntity({this.id, this.title, this.cover, this.dataList});

  @override
  ImdbListSubEntity.fromJson(dynamic json) {
    id = json['_id'];
    title = json['title'];
    cover = json['cover'];
    dataList = json['data_list'] == null
        ? null
        : List.from(json['data_list']).map((e) => MediaItemEntity.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['cover'] = cover;
    data['data_list'] = dataList?.map((e) => e.toJson()).toList();
    return data;
  }
}
