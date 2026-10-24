import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'constants.dart';

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static String? _sessionId;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      AuthInterceptor(_storage),
      SessionInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// Extracts clean, user-friendly error messages from Dio / API exceptions
  static String parseError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          // Check for validation errors object (Laravel format)
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errorsMap = data['errors'] as Map;
            final List<String> messages = [];
            errorsMap.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                messages.add(value.first.toString());
              } else if (value is String) {
                messages.add(value);
              }
            });
            if (messages.isNotEmpty) {
              return messages.join('\n');
            }
          }

          if (data.containsKey('message') &&
              data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            return data['message'].toString();
          }

          if (data.containsKey('error') &&
              data['error'] != null &&
              data['error'].toString().isNotEmpty) {
            return data['error'].toString();
          }
        } else if (data is String && data.isNotEmpty) {
          return data;
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'Network error. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Invalid email/phone or password. Please check your credentials.';
          } else if (statusCode == 422) {
            return 'Please fill in all required fields in the correct format.';
          } else if (statusCode == 404) {
            return 'Account or requested service not found.';
          } else if (statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          break;
        default:
          break;
      }
    }

    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.replaceFirst('Exception: ', '');
    }
    return str;
  }

  /// Helper to handle relative/absolute API images as per GOSIKA blueprint
  static String apiImage(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http') || path.startsWith('data:')) return path;

    // Normalize relative path
    String normalized = path;
    if (path.startsWith('/storage/')) {
      normalized = path.replaceFirst('/storage/', '');
    } else if (path.startsWith('storage/')) {
      normalized = path.replaceFirst('storage/', '');
    }

    // Prefix with host and storage path
    final origin = kBaseUrl.replaceFirst('/api/v1', '');
    return '$origin/storage/$normalized';
  }

  static Future<String> getSessionId() async {
    if (_sessionId != null) return _sessionId!;
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('x_session_id');
    if (_sessionId == null) {
      _sessionId = const Uuid().v4();
      await prefs.setString('x_session_id', _sessionId!);
    }
    return _sessionId!;
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: kTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class SessionInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final sessionId = await ApiClient.getSessionId();
    options.headers['X-Session-Id'] = sessionId;
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Automatic session clearing handled here or in provider
    }
    handler.next(err);
  }
}
