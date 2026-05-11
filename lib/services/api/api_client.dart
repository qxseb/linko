import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;

  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}

class ApiClient {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'LINKO_API_BASE_URL',
  );
  static const String _tokenKey = 'linko_jwt_token';

  final String baseUrl;
  final http.Client _client;

  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = (baseUrl ?? defaultBaseUrl).replaceFirst(RegExp(r'/$'), ''),
        _client = client ?? http.Client();

  static String get defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String?>? query,
    bool requiresAuth = false,
  }) {
    return _send('GET', path, query: query, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _send('POST', path, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _send('PATCH', path, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String?>? query,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = _buildUri(path, query);
      final headers = await _buildHeaders(requiresAuth);
      final encodedBody = body == null ? null : jsonEncode(body);

      late final Future<http.Response> request;
      if (method == 'GET') {
        request = _client.get(uri, headers: headers);
      } else if (method == 'POST') {
        request = _client.post(uri, headers: headers, body: encodedBody);
      } else if (method == 'PATCH') {
        request = _client.patch(uri, headers: headers, body: encodedBody);
      } else {
        throw const ApiException('Invalid API method');
      }

      final response = await request.timeout(const Duration(seconds: 8));

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'Server is not responding',
        isNetworkError: true,
      );
    } on http.ClientException {
      throw const ApiException(
        'Server is currently unavailable',
        isNetworkError: true,
      );
    } catch (_) {
      throw const ApiException(
        'Could not connect to the server',
        isNetworkError: true,
      );
    }
  }

  Uri _buildUri(String path, Map<String, String?>? query) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final filteredQuery = <String, String>{};

    query?.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        filteredQuery[key] = value;
      }
    });

    return Uri.parse('$baseUrl$cleanPath').replace(
      queryParameters: filteredQuery.isEmpty ? null : filteredQuery,
    );
  }

  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw const ApiException('Authentication required');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final rawBody = utf8.decode(response.bodyBytes);
    final decoded = rawBody.isEmpty ? <String, dynamic>{} : jsonDecode(rawBody);

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Invalid server response');
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        decoded['message']?.toString() ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
