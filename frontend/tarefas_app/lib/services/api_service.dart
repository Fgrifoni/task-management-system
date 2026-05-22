import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/auth_storage.dart';

class ApiService {
  Future<bool> _refreshToken() async {
    final refreshToken = AuthStorage.refreshToken;

    if (refreshToken == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/refresh'),

      headers: {'Authorization': 'Bearer $refreshToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await AuthStorage.saveTokens(
        access: data['accessToken'],
        refresh: refreshToken,
      );

      return true;
    }

    return false;
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',

      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, {String? token}) async {
    var response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),

      headers: _headers(token),
    );

    if (response.statusCode == 403) {
      final renovou = await _refreshToken();

      if (renovou) {
        response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),

          headers: _headers(AuthStorage.accessToken),
        );
      }
    }

    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    Object? body,
    String? token,
  }) async {
    var response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),

      headers: _headers(token),

      body: body == null ? null : jsonEncode(body),
    );

    if (response.statusCode == 403) {
      final renovou = await _refreshToken();

      if (renovou) {
        response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),

          headers: _headers(AuthStorage.accessToken),

          body: body == null ? null : jsonEncode(body),
        );
      }
    }

    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Object? body,
    String? token,
  }) async {
    var response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),

      headers: _headers(token),

      body: body == null ? null : jsonEncode(body),
    );

    if (response.statusCode == 403) {
      final renovou = await _refreshToken();

      if (renovou) {
        response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),

          headers: _headers(AuthStorage.accessToken),

          body: body == null ? null : jsonEncode(body),
        );
      }
    }

    return response;
  }

  Future<http.Response> delete(String endpoint, {String? token}) async {
    var response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$endpoint'),

      headers: _headers(token),
    );

    if (response.statusCode == 403) {
      final renovou = await _refreshToken();

      if (renovou) {
        response = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}$endpoint'),

          headers: _headers(AuthStorage.accessToken),
        );
      }
    }

    return response;
  }
}
