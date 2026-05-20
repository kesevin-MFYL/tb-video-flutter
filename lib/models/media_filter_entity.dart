import 'package:editvideo/config/network/model/base_entity.dart';

class MediaFilterEntity extends BaseEntity {
  List<String>? genreList;
  List<String>? yearList;
  List<String>? countryList;
  List<String>? countryCodeList;
  List<String>? sortByList;

  MediaFilterEntity({this.genreList, this.yearList, this.countryList, this.countryCodeList, this.sortByList});

  @override
  MediaFilterEntity.fromJson(dynamic json) {
    if (json['genre_list'] != null) {
      genreList = json['genre_list'].cast<String>();
    }
    if (json['year_list'] != null) {
      yearList = json['year_list'].cast<String>();
    }
    if (json['country_list'] != null) {
      countryList = json['country_list'].cast<String>();
    }
    if (json['country_code_list'] != null) {
      countryCodeList = json['country_code_list'].cast<String>();
    }
    if (json['sort_by_list'] != null) {
      sortByList = json['sort_by_list'].cast<String>();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['genre_list'] = genreList;
    data['year_list'] = yearList;
    data['country_list'] = countryList;
    data['country_code_list'] = countryCodeList;
    data['sort_by_list'] = sortByList;
    return data;
  }
}
