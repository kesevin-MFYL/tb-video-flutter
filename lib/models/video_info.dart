class VideoInfo {
  int? width;
  int? height;
  int? duration;
  String? path;
  int? size;
  String? thumbnailPath;

  VideoInfo({this.width, this.height, this.duration, this.path, this.size, this.thumbnailPath});

  VideoInfo.fromJson(dynamic json) {
    width = json['width'];
    height = json['height'];
    duration = json['duration'];
    path = json['path'];
    size = json['size'];
    thumbnailPath = json['thumbnailPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['width'] = width;
    data['height'] = height;
    data['duration'] = duration;
    data['path'] = path;
    data['size'] = size;
    data['thumbnailPath'] = thumbnailPath;
    return data;
  }

  VideoInfo copyWith({int? width, int? height, int? duration, String? path, int? size, String? thumbnailPath}) {
    return VideoInfo(
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      path: path ?? this.path,
      size: size ?? this.size,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
