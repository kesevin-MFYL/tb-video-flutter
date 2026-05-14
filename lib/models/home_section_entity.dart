import 'package:editvideo/config/network/model/base_entity.dart';

class HomeSectionEntity extends BaseEntity {
  int? id;
  String? title;
  String? kind;
  List<MediaItemEntity>? dataList;

  HomeSectionEntity({this.id, this.title, this.kind, this.dataList});

  @override
  HomeSectionEntity.fromJson(dynamic json) {
    if (json['_id'] != null) {
      id = int.tryParse(json['_id'].toString());
    }
    title = json['title'];
    kind = json['kind'];
    if (json['data_list'] != null) {
      dataList = [];
      json['data_list'].forEach((v) {
        dataList?.add(MediaItemEntity.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['kind'] = kind;
    if (dataList != null) {
      data['data_list'] = dataList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaItemEntity extends BaseEntity {
  int? id;
  String? imdbType;
  String? title;
  String? cover;
  String? pubDate;
  String? rate;
  String? quality;
  List<String>? genreList;
  int? type;
  double? storageTimestamp;
  String? trailer;
  String? certification;
  String? imdbId;
  List<MediaItemEntity>? dataList;

  MediaItemEntity({
    this.id,
    this.imdbType,
    this.title,
    this.cover,
    this.pubDate,
    this.rate,
    this.quality,
    this.genreList,
    this.type,
    this.storageTimestamp,
    this.trailer,
    this.certification,
    this.imdbId,
    this.dataList,
  });

  @override
  MediaItemEntity.fromJson(dynamic json) {
    if (json['_id'] != null) {
      id = int.tryParse(json['_id'].toString());
    }
    imdbType = json['imdb_type'];
    title = json['title'];
    cover = json['cover'];
    pubDate = json['pub_date'];
    rate = json['rate']?.toString();
    quality = json['quality'];
    if (json['genre_list'] != null) {
      genreList = json['genre_list'].cast<String>();
    }
    if (json['type'] != null) {
      type = int.tryParse(json['type'].toString());
    }
    if (json['storage_timestamp'] != null) {
      storageTimestamp = double.tryParse(json['storage_timestamp'].toString());
    }
    trailer = json['trailer'];
    certification = json['certification'];
    imdbId = json['imdb_id'];
    if (json['data_list'] != null) {
      dataList = [];
      json['data_list'].forEach((v) {
        dataList?.add(MediaItemEntity.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['imdb_type'] = imdbType;
    data['title'] = title;
    data['cover'] = cover;
    data['pub_date'] = pubDate;
    data['rate'] = rate;
    data['quality'] = quality;
    data['genre_list'] = genreList;
    data['type'] = type;
    data['storage_timestamp'] = storageTimestamp;
    data['trailer'] = trailer;
    data['certification'] = certification;
    data['imdb_id'] = imdbId;
    if (dataList != null) {
      data['data_list'] = dataList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
