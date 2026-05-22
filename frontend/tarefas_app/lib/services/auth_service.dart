import 'dart:convert';

import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse> login({
  required String email,
  required String senha,
}) async {
  final response = await _apiService.post(
    '/auth/login',
    body: {
      'email': email,
      'senha': senha,
    },
  );

  print('STATUS LOGIN: ${response.statusCode}');
  print('BODY LOGIN: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return AuthResponse.fromJson(data);
  }

  throw Exception('Erro ao fazer login: ${response.body}');
}
}