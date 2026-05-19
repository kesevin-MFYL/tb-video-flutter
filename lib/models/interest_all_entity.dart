import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/models/home_section_entity.dart';

class InterestAllEntity extends BaseEntity {
  String? title;
  List<MediaItemEntity>? dataList;

  InterestAllEntity({this.title, this.dataList});

  @override
  InterestAllEntity.fromJson(dynamic json) {
    title = json['title'];
    dataList = json['data_list'] == null
        ? null
        : List.from(json['data_list']).map((e) => MediaItemEntity.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['data_list'] = dataList?.map((e) => e.toJson()).toList();
    return data;
  }
}
