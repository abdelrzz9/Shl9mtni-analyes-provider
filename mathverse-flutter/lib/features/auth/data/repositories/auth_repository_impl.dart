import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository.dart' show AuthException;

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthTokens> register(
      String email, String password, String displayName) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      await saveTokens(tokens);
      _apiClient.setAccessToken(tokens.accessToken);
      return tokens;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ?? 'registration failed';
      throw AuthException(message);
    }
  }

  @override
  Future<AuthTokens> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      await saveTokens(tokens);
      _apiClient.setAccessToken(tokens.accessToken);
      return tokens;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] as String? ?? 'login failed';
      if (statusCode == 429) {
        throw AuthException('account is locked. try again later');
      }
      throw AuthException(message);
    }
  }

  @override
  Future<AuthTokens> refreshToken(String refreshTokenStr) async {
    try {
      final response = await _apiClient.post('/api/v1/auth/refresh', data: {
        'refreshToken': refreshTokenStr,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      await saveTokens(tokens);
      _apiClient.setAccessToken(tokens.accessToken);
      return tokens;
    } on DioException catch (e) {
      throw AuthException(e.response?.data?['message'] as String? ?? 'token refresh failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/api/v1/auth/logout');
    } catch (_) {
    }
    _apiClient.clearAccessToken();
    await clearTokens();
  }

  @override
  Future<User?> getProfile() async {
    try {
      final response = await _apiClient.get('/api/v1/auth/profile');
      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.accessToken);
    await prefs.setString('refresh_token', tokens.refreshToken);
    await prefs.setInt('expires_in', tokens.expiresIn);
    await prefs.setString('user_id', tokens.userId);
    await prefs.setString('display_name', tokens.displayName);
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('expires_in');
    await prefs.remove('user_id');
    await prefs.remove('display_name');
  }
}


