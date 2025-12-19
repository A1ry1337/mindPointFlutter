import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:te4st_proj_flut/config/app_config.dart';
import 'package:te4st_proj_flut/core/routers/app_router.dart';
import 'package:te4st_proj_flut/core/services/storage_service.dart';
import 'package:go_router/go_router.dart';

class ApiService {
  final String baseUrl = AppConfig.apiUrl;
  final bool _enableLogging = true; // Включить/выключить логирование

  static GlobalKey<NavigatorState> get navigatorKey => AppRouter.navigatorKey;

  void _log(String message) {
    if (_enableLogging) {
      print('🔵 [API] $message');
    }
  }

  void _logRequest(String method, String url, Map<String, dynamic>? data, Map<String, String> headers) {
    _log('╔═══════════════════════════════════════════════════════');
    _log('║ 📤 REQUEST: $method $url');
    _log('╟───────────────────────────────────────────────────────');

    if (headers.isNotEmpty) {
      _log('║ 📋 HEADERS:');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          _log('║   $key: Bearer *****${value.substring(value.length - 5)}');
        } else {
          _log('║   $key: $value');
        }
      });
    }

    if (data != null && data.isNotEmpty) {
      _log('║ 📦 BODY:');
      final prettyJson = JsonEncoder.withIndent('  ').convert(data);
      prettyJson.split('\n').forEach((line) {
        _log('║   $line');
      });
    }
    _log('╚═══════════════════════════════════════════════════════');
  }

  void _logResponse(String method, String url, int statusCode, dynamic data, String? error) {
    _log('╔═══════════════════════════════════════════════════════');
    _log('║ 📥 RESPONSE: $method $url');
    _log('║ 📊 STATUS CODE: $statusCode ${_getStatusMessage(statusCode)}');
    _log('╟───────────────────────────────────────────────────────');

    if (error != null) {
      _log('║ ❌ ERROR: $error');
    }

    if (data != null && data.isNotEmpty) {
      _log('║ 📦 BODY:');
      final prettyJson = JsonEncoder.withIndent('  ').convert(data);
      prettyJson.split('\n').forEach((line) {
        _log('║   $line');
      });
    }
    _log('╚═══════════════════════════════════════════════════════');
  }

  void _logError(String method, String url, dynamic error, StackTrace stackTrace) {
    _log('╔═══════════════════════════════════════════════════════');
    _log('║ 🚨 EXCEPTION: $method $url');
    _log('╟───────────────────────────────────────────────────────');
    _log('║ 🔥 ERROR: $error');
    _log('║ 🔍 STACK TRACE:');
    stackTrace.toString().split('\n').take(5).forEach((line) {
      _log('║   $line');
    });
    _log('╚═══════════════════════════════════════════════════════');
  }

  String _getStatusMessage(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return '✅ OK';
    if (statusCode == 401) return '🔐 Unauthorized';
    if (statusCode == 403) return '🚫 Forbidden';
    if (statusCode == 404) return '❌ Not Found';
    if (statusCode >= 500) return '💥 Server Error';
    return '⚠️ Client Error';
  }

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data,
      {bool authRequired = false}
      ) async {
    final url = '$baseUrl$endpoint';
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (authRequired) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    _logRequest('POST', url, data, headers);

    try {
      final startTime = DateTime.now();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );
      final duration = DateTime.now().difference(startTime);

      Map<String, dynamic>? responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        _log('⚠️ Не удалось распарсить JSON ответ');
      }

      _log('⏱️ Время выполнения: ${duration.inMilliseconds}ms');

      if (response.statusCode == 401) {
        _logResponse('POST', url, response.statusCode, responseData, 'Unauthorized - токен истек');
        await StorageService.clearStorage();

        final context = navigatorKey.currentContext;

        if (context != null && context.mounted) {
          _log('🔄 Перенаправление на /login через GoRouter');
          context.go('/login');
        }

        throw Exception('Unauthorized');
      }

      _logResponse('POST', url, response.statusCode, responseData, null);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData ?? {'success': true};
      } else {
        final error = responseData?['message'] ?? responseData?['error'] ?? 'Request failed';
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      _logError('POST', url, e, stackTrace);
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint, {bool authRequired = false, Map<String, String>? queryParams}) async {

    String url = '$baseUrl$endpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = Uri(queryParameters: queryParams).query;
      url = '$url?$queryString';
    }

    final headers = <String, String>{};

    if (authRequired) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    _logRequest('GET', url, null, headers);

    try {
      final startTime = DateTime.now();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      final duration = DateTime.now().difference(startTime);

      dynamic responseData;

      try {
        responseData = json.decode(response.body);
      } catch (e) {
        _log('⚠️ Не удалось распарсить JSON ответ: $e');
        rethrow;
      }

      _log('⏱️ Время выполнения: ${duration.inMilliseconds}ms');

      if (response.statusCode == 401) {
        _logResponse('GET', url, response.statusCode, responseData, 'Unauthorized - токен истек');

        await StorageService.clearStorage();

        final context = navigatorKey.currentContext;

        if (context != null && context.mounted) {
          _log('🔄 Перенаправление на /login через GoRouter');
          context.go('/login');
        }
        throw Exception('Unauthorized');
      }

      _logResponse('GET', url, response.statusCode, responseData, null);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        if (responseData is Map<String, dynamic>) {
          final error = responseData['message'] ??
              responseData['error'] ??
              'Request failed';
          throw Exception(error);
        } else {
          throw Exception('Request failed');
        }
      }
    } catch (e, stackTrace) {
      _logError('GET', url, e, stackTrace);
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {bool authRequired = false}) async {
    final url = '$baseUrl$endpoint';
    final headers = <String, String>{};

    if (authRequired) {
      final token = await StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    _logRequest('DELETE', url, null, headers);

    try {
      final startTime = DateTime.now();
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      final duration = DateTime.now().difference(startTime);

      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = json.decode(response.body);
        } catch (e) {
          _log('⚠️ Не удалось распарсить JSON ответ: $e');
        }
      }

      _log('⏱️ Время выполнения: ${duration.inMilliseconds}ms');

      if (response.statusCode == 401) {
        _logResponse('DELETE', url, response.statusCode, responseData, 'Unauthorized - токен истек');
        await StorageService.clearStorage();

        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          _log('🔄 Перенаправление на /login через GoRouter');
          context.go('/login');
        }
        throw Exception('Unauthorized');
      }

      _logResponse('DELETE', url, response.statusCode, responseData, null);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData ?? {'success': true};
      } else {
        final error = responseData is Map<String, dynamic>
            ? (responseData['message'] ?? responseData['error'] ?? 'Request failed')
            : 'Request failed';
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      _logError('DELETE', url, e, stackTrace);
      rethrow;
    }
  }
}