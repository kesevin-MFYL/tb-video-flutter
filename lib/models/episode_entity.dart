import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/models/caption_entity.dart';

class EpisodeEntity extends BaseEntity {
  int? id;
  int? epsNum;
  String? title;
  String? video;
  String? masterM3u8;
  String? cover;
  String? overview;
  int? runtime;
  List<CaptionEntity>? captionList;
  double? storageTimestamp;

  EpisodeEntity({
    this.id,
    this.epsNum,
    this.title,
    this.video,
    this.masterM3u8,
    this.cover,
    this.overview,
    this.runtime,
    this.captionList,
    this.storageTimestamp,
  });

  @override
  EpisodeEntity.fromJson(dynamic json) {
    id = json['_id'];
    epsNum = json['eps_num'];
    title = json['title'];
    video = json['video'];
    masterM3u8 = json['master_m3u8'];
    cover = json['cover'];
    overview = json['overview'];
    runtime = json['runtime'];
    captionList = json['caption_list'] == null
        ? null
        : List.from(json['caption_list']).map((e) => CaptionEntity.fromJson(e)).toList();
    storageTimestamp = json['storage_timestamp'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['eps_num'] = epsNum;
    data['title'] = title;
    data['video'] = video;
    data['master_m3u8'] = masterM3u8;
    data['cover'] = cover;
    data['overview'] = overview;
    data['runtime'] = runtime;
    data['caption_list'] = captionList?.map((v) => v.toJson()).toList();
    data['storage_timestamp'] = storageTimestamp;
    return data;
  }
}
