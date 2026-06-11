import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await ApiService.post('/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    await _saveAuthData(result);
    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiService.post('/login', body: {
      'email': email,
      'password': password,
    });
    await _saveAuthData(result);
    return result;
  }

  static Future<void> logout() async {
    try {
      await ApiService.post('/logout');
    } finally {
      await ApiService.clearToken();
    }
  }

  static Future<void> _saveAuthData(Map<String, dynamic> result) async {
    final token = result['token'];
    final user = result['user'];
    final prefs = await SharedPreferences.getInstance();
    await ApiService.setToken(token);
    await prefs.setString('user_role', user['role']);
    await prefs.setString('user_name', user['name']);
    await prefs.setInt('user_id', user['id']);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}
