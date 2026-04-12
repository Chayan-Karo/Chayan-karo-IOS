// lib/data/remote/network_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class NetworkClient {
  // Singleton instance
  static final NetworkClient _instance = NetworkClient._internal();

  late final Dio _dio;
  late final ApiService _apiService;

  NetworkClient._internal() {
    // Use the same HTTPS base URL as ApiService annotation to avoid conflicts
    const String base = 'https://api.chayankaro.com';

    _dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptors: logging first to see mutations from auth too
    _dio.interceptors.add(_createVerboseLogger());
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());

    // Ensure ApiService uses the same base
    _apiService = ApiService(_dio, baseUrl: base);
  }

  factory NetworkClient() => _instance;

  ApiService get apiService => _apiService;
  Dio get dio => _dio;

  // Verbose logger that shows true JSON body on wire
  InterceptorsWrapper _createVerboseLogger() => InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 API: ${options.method} ${options.uri}');
          print('🌐 API: headers: ${options.headers}');
          final data = options.data;
          if (data != null) {
            print('🌐 API: data type => ${data.runtimeType}');
            if (data is Map || data is List) {
              try {
                print('🌐 API: data => ${jsonEncode(data)}');
              } catch (_) {
                print('🌐 API: data (non-json-encodable) => $data');
              }
            } else {
              print('🌐 API: data => $data');
            }
          }
          handler.next(options);
        },
        onResponse: (resp, handler) {
          print('🌐 API: status: ${resp.statusCode}');
          print('🌐 API: response type => ${resp.data.runtimeType}');
          // Avoid dumping huge bodies; print small JSON safely
          try {
            if (resp.data is Map || resp.data is List) {
              final s = jsonEncode(resp.data);
              if (s.length < 4000) print('🌐 API: response => $s');
            }
          } catch (_) {
            // ignore encoding errors
          }
          handler.next(resp);
        },
        onError: (err, handler) {
          print('🌐 API: error: ${err.type} ${err.message}');
          if (err.response != null) {
            print('🌐 API: error status: ${err.response?.statusCode}');
            try {
              final d = err.response?.data;
              if (d is Map || d is List) {
                print('🌐 API: error body => ${jsonEncode(d)}');
              } else {
                print('🌐 API: error body => $d');
              }
            } catch (_) {
              // ignore
            }
          }
          handler.next(err);
        },
      );

  InterceptorsWrapper _createAuthInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getStoredToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      );

  InterceptorsWrapper _createErrorInterceptor() => InterceptorsWrapper(
        onError: (error, handler) {
          _handleDioError(error);
          final request = error.requestOptions;

    FirebaseCrashlytics.instance.recordError(
      error,
      error.stackTrace ,
      reason: "API ERROR: ${request.method} ${request.uri} | STATUS: ${error.response?.statusCode} | RESPONSE: ${error.response?.data}",
    );

          handler.next(error);
        },
      );

  // TODO: wire this to your AppDatabase().getAuthToken()
  Future<String?> _getStoredToken() async {
    return null;
  }

  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        print('❌ Connection timeout');
        break;
      case DioExceptionType.sendTimeout:
        print('❌ Send timeout');
        break;
      case DioExceptionType.receiveTimeout:
        print('❌ Receive timeout');
        break;
      case DioExceptionType.badResponse:
        print('❌ Bad response: ${error.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        print('❌ Request cancelled');
        break;
      case DioExceptionType.connectionError:
        print('❌ Connection error');
        break;
      case DioExceptionType.badCertificate:
        print('❌ Bad certificate error');
        break;
      case DioExceptionType.unknown:
        print('❌ Unknown error: ${error.message}');
        break;
    }
  }
}
