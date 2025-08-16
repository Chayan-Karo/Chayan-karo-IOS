import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DioClient {
  static const String _baseUrl = 'https://your-api-base-url.com'; // TODO: Replace with your API URL
  static const int _connectTimeout = 60000;
  static const int _receiveTimeout = 60000;

  late final Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: Duration(milliseconds: _connectTimeout),
      receiveTimeout: Duration(milliseconds: _receiveTimeout),
      responseType: ResponseType.json,
    ));

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));

    // TODO: Add authentication interceptor if needed
    // _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;
}
