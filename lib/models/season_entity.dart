import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/widget/tabbar/common_tab_bar.dart';

class SeasonEntity extends BaseEntity implements TabBarItem {
  int? id;
  String? title;
  String? cover;

  SeasonEntity({this.id, this.title, this.cover});

  @override
  SeasonEntity.fromJson(dynamic json) {
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

  @override
  String? get markIcon => null;

  @override
  String? get tabIcon => null;

  @override
  String get tabText => title ?? '';
}
