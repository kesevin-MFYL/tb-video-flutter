import 'package:logger/logger.dart';

class LoggerConfig {
  late final Logger logger;
  bool _lock = false;

  static final LoggerConfig instance = LoggerConfig._internal();

  LoggerConfig._internal();

  factory LoggerConfig.instantiate() {
    if (instance._lock) return instance;

    instance.logger = Logger(
      printer: PrettyPrinter(
        methodCount: LoggerConfigValues.loggerMethodCount,
        errorMethodCount: LoggerConfigValues.loggerErrorMethodCount,
        lineLength: LoggerConfigValues.loggerLineLength,
        colors: true,
        printEmojis: true,
      ),
    );
    instance._lock = true;

    return instance;
  }
}

abstract class LoggerConfigValues {
  static const int loggerLineLength = 120;
  static const int loggerErrorMethodCount = 8;
  static const int loggerMethodCount = 2;
}