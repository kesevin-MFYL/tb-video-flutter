import 'package:dio/dio.dart';
import 'package:editvideo/config/log/logger.dart';

class LoggingInterceptor extends Interceptor {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    commonDebugPrint('-------------------- Start --------------------');
    commonDebugPrint('RequestUrl: ${options.baseUrl}----${options.path}', needSplit: true);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _endTime = DateTime.now();
    final int duration = _endTime.difference(_startTime).inMilliseconds;
    commonDebugPrint('-------------------- End: $duration 毫秒 --------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    commonDebugPrint('-------------------- Error --------------------');
    super.onError(err, handler);
  }
}
