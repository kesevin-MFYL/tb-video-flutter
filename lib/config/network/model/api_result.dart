class ApiResult<T, E extends Error> {
  T? responseData;
  E? error;

  ApiResult._(this.responseData, this.error);

  factory ApiResult.succss(T data) {
    return ApiResult._(data, null);
  }

  factory ApiResult.failure(
      E error, {
        T? responseData,
      }) {
    return ApiResult._(responseData, error);
  }

  bool get isSuccess => error == null;
  bool get isFailure => !isSuccess;
}