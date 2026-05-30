import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'storage_service.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = Constants.apiBaseUrl;
  
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('📡 Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('📡 Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await StorageService.clearAll();
        }
        return handler.next(error);
      },
    ));
    
    return dio;
  }

  static final Dio _dio = _createDio();

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'user': response.data['user'],
          'token': response.data['token'],
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  static Future<List<dynamic>> getMyChannels() async {
    try {
      final response = await _dio.get('/customers/my-channels');
      print('📺 Got ${response.data['channels']?.length ?? 0} channels');
      return response.data['channels'] ?? [];
    } catch (e) {
      print('❌ Error fetching channels: $e');
      return [];
    }
  }

  static Future<String?> getStreamUrl({
    required String? playlistId,
    required String? channelId,
    String? cmd,
    bool useProxy = false,
  }) async {
    try {
      print('🔗 Requesting stream URL for channelId: $channelId');
      
      final response = await _dio.post('/channels/get-stream-single', data: {
        'playlistId': playlistId,
        'channelId': channelId,
        'cmd': cmd ?? '',
      });
      
      String? url = response.data['url'];
      print('🔗 Raw URL from API: $url');
      
      if (useProxy && url != null) {
        url = '$proxyBase?url=${Uri.encodeComponent(url)}';
        print('🔗 Proxied URL: $url');
      }
      
      return url;
    } catch (e) {
      print('❌ Error getting stream URL: $e');
      return null;
    }
  }

  static Future<void> releaseStream({
    String? playlistId,
    String? channelId,
    String? cmd,
  }) async {
    try {
      await _dio.post('/channels/release-stream', data: {
        'playlistId': playlistId,
        'channelId': channelId,
        'cmd': cmd ?? '',
      });
    } catch (e) {
      // Ignore release errors
    }
  }
  
  static String get proxyBase => '${baseUrl.replaceAll('/api', '')}/proxy/stream';
}