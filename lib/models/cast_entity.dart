import 'package:editvideo/config/network/model/base_entity.dart';

class Cast extends BaseEntity {
  int? id;
  String? name;
  int? gender;
  String? biography;
  String? birthday;
  String? deathday;
  String? placeOfBirth;
  String? cover;

  Cast({this.id, this.name, this.gender, this.biography, this.birthday, this.deathday, this.placeOfBirth, this.cover});

  @override
  Cast.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    gender = json['gender'];
    biography = json['biography'];
    birthday = json['birthday'];
    deathday = json['deathday'];
    placeOfBirth = json['place_of_birth'];
    cover = json['cover'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['gender'] = gender;
    data['biography'] = biography;
    data['birthday'] = birthday;
    data['deathday'] = deathday;
    data['place_of_birth'] = placeOfBirth;
    data['cover'] = cover;
    return data;
  }
}