abstract class BaseEntity {
  BaseEntity();

  BaseEntity.fromJson(dynamic json);

  dynamic toJson();
}

class VoidObject extends BaseEntity {
  VoidObject.fromJson(dynamic json);

  @override
  dynamic toJson() {
    return <String, dynamic>{};
  }
}