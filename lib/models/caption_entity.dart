import 'package:editvideo/config/network/model/base_entity.dart';

class CaptionEntity extends BaseEntity {
  String? name;
  String? displayName;
  String? shortName;
  String? s3Address;

  CaptionEntity({this.name, this.displayName, this.shortName, this.s3Address});

  @override
  CaptionEntity.fromJson(dynamic json) {
    name = json['name'];
    displayName = json['display_name'];
    shortName = json['short_name'];
    s3Address = json['s3_address'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['display_name'] = displayName;
    data['short_name'] = shortName;
    data['s3_address'] = s3Address;
    return data;
  }
}