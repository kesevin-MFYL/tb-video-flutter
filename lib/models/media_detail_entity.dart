import 'package:editvideo/config/network/model/base_entity.dart';
import 'package:editvideo/models/caption_entity.dart';
import 'package:editvideo/models/cast_entity.dart';
import 'package:editvideo/utils/extension.dart';

class MediaDetailEntity extends BaseEntity {
  int? id;
  String? video;
  String? masterM3u8;
  String? title;
  String? cover;
  String? quality;
  String? horizontalCover;
  String? description;
  String? pubDate;
  String? country;
  List<String>? countryCodeList;
  String? rate;
  String? lang;
  String? certification;
  String? trailer;
  String? imdbId;
  List<Cast>? cast;
  List<Images>? images;
  List<String>? genreList;
  List<CaptionEntity>? captionList;

  MediaDetailEntity({
    this.id,
    this.video,
    this.masterM3u8,
    this.title,
    this.cover,
    this.quality,
    this.horizontalCover,
    this.description,
    this.pubDate,
    this.country,
    this.countryCodeList,
    this.rate,
    this.lang,
    this.certification,
    this.trailer,
    this.imdbId,
    this.cast,
    this.images,
    this.genreList,
    this.captionList,
  });

  @override
  MediaDetailEntity.fromJson(dynamic json) {
    id = json['_id'];
    video = json['video'];
    masterM3u8 = json['master_m3u8'];
    title = json['title'];
    cover = json['cover'];
    quality = json['quality'];
    horizontalCover = json['horizontal_cover'];
    description = json['description'];
    pubDate = json['pub_date'];
    country = json['country'];
    if (json['country_code_list'] != null) {
      countryCodeList = json['country_code_list'].cast<String>();
    }
    rate = json['rate'];
    lang = json['lang'];
    certification = json['certification'];
    trailer = json['trailer'];
    imdbId = json['imdb_id'];
    cast = json['cast'] == null ? null : List.from(json['cast']).map((e) => Cast.fromJson(e)).toList();
    images = json['images'] == null ? null : List.from(json['images']).map((e) => Images.fromJson(e)).toList();
    if (json['genre_list'] != null) {
      genreList = json['genre_list'].cast<String>();
    }
    captionList = json['caption_list'] == null
        ? null
        : List.from(json['caption_list']).map((e) => CaptionEntity.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['video'] = video;
    data['master_m3u8'] = masterM3u8;
    data['title'] = title;
    data['cover'] = cover;
    data['quality'] = quality;
    data['horizontal_cover'] = horizontalCover;
    data['description'] = description;
    data['pub_date'] = pubDate;
    data['country'] = country;
    data['country_code_list'] = countryCodeList;
    data['rate'] = rate;
    data['lang'] = lang;
    data['certification'] = certification;
    data['trailer'] = trailer;
    data['imdb_id'] = imdbId;
    data['cast'] = cast?.map((v) => v.toJson()).toList();
    data['images'] = images?.map((v) => v.toJson()).toList();
    data['genre_list'] = genreList;
    data['caption_list'] = captionList?.map((v) => v.toJson()).toList();
    return data;
  }

  String? get countryString => countryCodeList != null && countryCodeList!.isNotEmpty ? countryCodeList!.first : null;

  String? get year => pubDate.isNotEmptyString() && pubDate!.length >= 4 ? pubDate?.substring(0, 4) : null;
}

class Images extends BaseEntity {
  String? url;
  int? imgMode;

  Images({this.url, this.imgMode});

  @override
  Images.fromJson(dynamic json) {
    url = json['url'];
    imgMode = json['img_mode'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['img_mode'] = imgMode;
    return data;
  }
}
