import 'package:editvideo/config/network/model/base_entity.dart';

class IpConfigEntity extends BaseEntity {
  String? ip;
  String? country;
  String? subdivision;

  IpConfigEntity({this.ip, this.country, this.subdivision});

  @override
  IpConfigEntity.fromJson(dynamic json) {
    ip = json['ip'];
    country = json['country'];
    subdivision = json['subdivision'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ip'] = ip;
    data['country'] = country;
    data['subdivision'] = subdivision;
    return data;
  }
}