import 'dart:io';

enum MediaDataSourceType { asset, network, file, contentUri }

/// 媒体数据源
class MediaDataSource {
  File? file;
  String? videoSource;
  String? audioSource;
  String? subFiles;
  MediaDataSourceType type;
  Map<String, String>? httpHeaders;

  MediaDataSource({this.file, this.videoSource, this.audioSource, this.subFiles, required this.type, this.httpHeaders})
    : assert((type == MediaDataSourceType.file && file != null) || videoSource != null);

  MediaDataSource copyWith({
    File? file,
    String? videoSource,
    String? audioSource,
    String? subFiles,
    MediaDataSourceType? type,
    Map<String, String>? httpHeaders,
  }) {
    return MediaDataSource(
      file: file ?? this.file,
      videoSource: videoSource ?? this.videoSource,
      audioSource: audioSource ?? this.audioSource,
      subFiles: subFiles ?? this.subFiles,
      type: type ?? this.type,
      httpHeaders: httpHeaders ?? this.httpHeaders,
    );
  }
}
