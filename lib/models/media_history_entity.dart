import 'package:editvideo/config/network/model/base_entity.dart';

class MediaHistoryEntity extends BaseEntity {
  int? id;
  String? title;
  String? cover;
  int? type;
  int? viewTime;
  int? totalDuration;
  int? currentDuration;

  MediaHistoryEntity({
    this.id,
    this.title,
    this.cover,
    this.type,
    this.viewTime,
    this.totalDuration,
    this.currentDuration,
  });

  @override
  MediaHistoryEntity.fromJson(dynamic json) {
    if (json['_id'] != null) {
      id = int.tryParse(json['_id'].toString());
    }
    title = json['title'];
    cover = json['cover'];
    if (json['type'] != null) {
      type = int.tryParse(json['type'].toString());
    }
    if (json['view_time'] != null) {
      viewTime = int.tryParse(json['view_time'].toString());
    }
    if (json['total_duration'] != null) {
      totalDuration = int.tryParse(json['total_duration'].toString());
    }
    if (json['current_duration'] != null) {
      currentDuration = int.tryParse(json['current_duration'].toString());
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['cover'] = cover;
    data['type'] = type;
    data['view_time'] = viewTime;
    data['total_duration'] = totalDuration;
    data['current_duration'] = currentDuration;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaHistoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}