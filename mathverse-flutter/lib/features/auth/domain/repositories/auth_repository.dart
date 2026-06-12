import '../entities/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<AuthTokens> register(String email, String password, String displayName);
  Future<AuthTokens> login(String email, String password);
  Future<AuthTokens> refreshToken(String refreshToken);
  Future<void> logout();
  Future<User?> getProfile();
  Future<String?> getAccessToken();
  Future<bool> isLoggedIn();
  Future<void> saveTokens(AuthTokens tokens);
  Future<void> clearTokens();
}
