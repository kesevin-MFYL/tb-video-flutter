import 'package:editvideo/config/log/logger_config.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

Logger get defaultLogger => LoggerConfig.instance.logger;

void commonDebugPrint(
  Object? object, {
  bool needSplit = false,
}) {
  if (kDebugMode) {
    final content = object.toString();
    if (needSplit) {
      defaultLogger.d(content);
    } else {
      print(content);
    }
  }
}
