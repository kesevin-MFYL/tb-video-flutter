import 'package:editvideo/models/video_info.dart';

class MemoryInfo {
  String? id;
  VideoInfo? videoInfo;
  String? title;
  int? videoTime;
  String? person;
  String? memo;

  MemoryInfo({
    this.id,
    this.videoInfo,
    this.title,
    this.videoTime,
    this.person,
    this.memo,
  });

  MemoryInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoInfo = json['videoInfo'] != null
        ? VideoInfo.fromJson(json['videoInfo'])
        : null;
    title = json['title'];
    videoTime = json['videoTime'];
    person = json['person'];
    memo = json['memo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (videoInfo != null) {
      data['videoInfo'] = videoInfo!.toJson();
    }
    data['title'] = title;
    data['videoTime'] = videoTime;
    data['person'] = person;
    data['memo'] = memo;
    return data;
  }

  MemoryInfo copyWith({
    String? id,
    VideoInfo? videoInfo,
    String? title,
    int? videoTime,
    String? person,
    String? memo,
  }) {
    return MemoryInfo(
      id: id ?? this.id,
      videoInfo: videoInfo ?? this.videoInfo,
      title: title ?? this.title,
      videoTime: videoTime ?? this.videoTime,
      person: person ?? this.person,
      memo: memo ?? this.memo,
    );
  }
}
