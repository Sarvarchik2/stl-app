import 'package:shared_preferences/shared_preferences.dart';
import 'package:stl_app/core/api/api_client.dart';
import 'package:stl_app/core/api/api_endpoints.dart';
import 'package:stl_app/features/auth/data/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRepository(this._apiClient, this._prefs);

  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    String? email,
    String? code,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'phone': phone,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (email != null) 'email': email,
        if (code != null) 'code': code,
      },
    );

    if (response.statusCode == 200) {
      if (code != null) {
        // Step 2: Completed
        final token = response.data['tokens']['access_token'];
        final refreshToken = response.data['tokens']['refresh_token'];
        await _prefs.setString('access_token', token);
        await _prefs.setString('refresh_token', refreshToken);
      }
      return response.data;
    } else {
      throw Exception(response.data['detail'] ?? 'Registration failed');
    }
  }

  Future<void> login(String phone, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone': phone,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final token = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      await _prefs.setString('access_token', token);
      await _prefs.setString('refresh_token', refreshToken);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<UserModel> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<void> logout() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
  }

  bool get isLoggedIn => _prefs.getString('access_token') != null;
}
