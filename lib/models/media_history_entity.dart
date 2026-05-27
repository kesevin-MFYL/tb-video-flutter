import 'package:editvideo/config/network/model/base_entity.dart';

class MediaHistoryEntity extends BaseEntity {
  int? id;
  String? title;
  String? cover;
  int? type;
  int? viewTime;
  int? totalDuration;
  int? currentDuration;
  int? seasonId;
  int? episodeId;
  int? epsNum;

  MediaHistoryEntity({
    this.id,
    this.title,
    this.cover,
    this.type,
    this.viewTime,
    this.totalDuration,
    this.currentDuration,
    this.seasonId,
    this.episodeId,
    this.epsNum,
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
    if (json['seasonId'] != null) {
      seasonId = int.tryParse(json['seasonId'].toString());
    }
    if (json['episodeId'] != null) {
      episodeId = int.tryParse(json['episodeId'].toString());
    }
    if (json['epsNum'] != null) {
      epsNum = int.tryParse(json['epsNum'].toString());
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
    data['seasonId'] = seasonId;
    data['episodeId'] = episodeId;
    data['epsNum'] = epsNum;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaHistoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  bool get isMovie => type == 1;

  bool get isTv => type == 2;

  String get remainingTimeText {
    if (totalDuration == null || currentDuration == null) return '';
    if (totalDuration! <= 0) return '';
    final remaining = totalDuration! - currentDuration!;
    if (remaining <= 0) return '0m remaining';
    
    final int hours = remaining ~/ 60;
    final int minutes = remaining % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }

  String get progressText {
    if (totalDuration == null || currentDuration == null) return '';
    if (totalDuration! <= 0) return '';
    final double progress = (currentDuration! / totalDuration!) * 100;
    return '${progress.toInt()}%';
  }
}