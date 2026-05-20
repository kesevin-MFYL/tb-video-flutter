import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/utils/extension.dart';
import 'package:editvideo/widget/tabbar/common_tab_bar.dart';

enum SectionType {
  none('none'),
  imdbList('imdb_list'), //合集list
  mediaList('media_list'), //单片
  topPicks('top_picks'),
  imdbInterest('imdb_interest'), //兴趣分类
  streamingMedia('streaming_media'); //渠道

  final String value;

  const SectionType(this.value);

  static SectionType kind(String? kind) {
    if (kind == imdbList.value) {
      return imdbList;
    } else if (kind == mediaList.value) {
      return mediaList;
    } else if (kind == imdbInterest.value) {
      return imdbInterest;
    } else if (kind == streamingMedia.value) {
      return streamingMedia;
    }
    return none;
  }
}

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
    dataList = json['data_list'] == null
        ? null
        : List.from(json['data_list']).map((e) => MediaItemEntity.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['kind'] = kind;
    data['data_list'] = dataList?.map((e) => e.toJson()).toList();
    return data;
  }
}

class MediaItemEntity extends BaseEntity implements TabBarItem {
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
  String? description;
  List<String>? countryCodeList;
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
    this.description,
    this.countryCodeList,
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
    description = json['description'];
    if (json['country_code_list'] != null) {
      countryCodeList = json['country_code_list'].cast<String>();
    }
    dataList = json['data_list'] == null
        ? null
        : List.from(json['data_list']).map((e) => MediaItemEntity.fromJson(e)).toList();
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
    data['description'] = description;
    data['country_code_list'] = countryCodeList;
    data['data_list'] = dataList?.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String? get markIcon => null;

  @override
  String? get tabIcon => null;

  @override
  String get tabText => title ?? '';

  String? get country => countryCodeList != null && countryCodeList!.isNotEmpty ? countryCodeList!.first : null;

  String? get year => pubDate.isNotEmptyString() && pubDate!.length >= 4 ? pubDate?.substring(0, 4) : null;
}
