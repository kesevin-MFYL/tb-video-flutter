import 'dart:io';

enum VideoType {
  video(1),
  tv(2);

  final int value;

  const VideoType(this.value);

  static VideoType instance(int? type) {
    if (type == VideoType.tv.value) {
      return VideoType.tv;
    } else {
      return VideoType.video;
    }
  }
}

enum MediaDataSourceType { asset, network, file, contentUri }

/// 媒体数据源
class MediaDataSource {
  File? file;
  String? videoSource;
  String? audioSource;
  String? subFiles;
  MediaDataSourceType type;
  VideoType videoType;
  Map<String, String>? httpHeaders;

  MediaDataSource({this.file, this.videoSource, this.audioSource, this.subFiles, required this.type, required this.videoType, this.httpHeaders})
    : assert((type == MediaDataSourceType.file && file != null) || videoSource != null);

  MediaDataSource copyWith({
    File? file,
    String? videoSource,
    String? audioSource,
    String? subFiles,
    MediaDataSourceType? type,
    VideoType? videoType,
    Map<String, String>? httpHeaders,
  }) {
    return MediaDataSource(
      file: file ?? this.file,
      videoSource: videoSource ?? this.videoSource,
      audioSource: audioSource ?? this.audioSource,
      subFiles: subFiles ?? this.subFiles,
      type: type ?? this.type,
      videoType: videoType ?? this.videoType,
      httpHeaders: httpHeaders ?? this.httpHeaders,
    );
  }
}
