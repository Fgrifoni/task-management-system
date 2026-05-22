import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static String? accessToken;
  static String? refreshToken;

  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    accessToken = access;
    refreshToken = refresh;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
  }

  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();

    accessToken = prefs.getString('accessToken');
    refreshToken = prefs.getString('refreshToken');
  }

  static Future<void> clear() async {
    accessToken = null;
    refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  static bool get isLoggedIn => accessToken != null;
}
