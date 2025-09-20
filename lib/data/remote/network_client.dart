import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'api_service.dart';

class NetworkClient {
  static NetworkClient? _instance;
  static final _lock = Object();
  
  late Dio _dio;
  late ApiService _apiService;

  // Private constructor
  NetworkClient._internal() {
    _initializeDio();
    _apiService = ApiService(_dio);
  }

  // Singleton factory
  factory NetworkClient() {
    if (_instance == null) {
      synchronized(_lock, () {
        _instance ??= NetworkClient._internal();
      });
    }
    return _instance!;
  }

  ApiService get apiService => _apiService;

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://65.1.234.42:8081',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  LogInterceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (obj) => print('🌐 API: $obj'),
    );
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        _handleDioError(error);
        handler.next(error);
      },
    );
  }

  Future<String?> _getStoredToken() async {
    try {
      // Get token from your storage (SharedPreferences, Secure Storage, etc.)
      // For now, return null - implement based on your storage solution
      return null;
    } catch (e) {
      return null;
    }
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

// Helper function for synchronization
void synchronized(Object lock, void Function() criticalSection) {
  criticalSection();
}
