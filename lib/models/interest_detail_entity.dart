import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';

class InterestDetailEntity extends BaseEntity{
  int? id;
  String? title;
  String? cover;
  String? description;
  List<HomeSectionEntity>? dataList;

  InterestDetailEntity({this.id, this.title, this.cover, this.description, this.dataList});

  @override
  InterestDetailEntity.fromJson(dynamic json) {
    id = json['_id'];
    title = json['title'];
    cover = json['cover'];
    description = json['description'];
    dataList = json['data_list'] == null
        ? null
        : List.from(json['data_list']).map((e) => HomeSectionEntity.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['cover'] = cover;
    data['description'] = description;
    data['data_list'] = dataList?.map((e) => e.toJson()).toList();
    return data;
  }
}
