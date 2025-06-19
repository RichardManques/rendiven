class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getMe = '/auth/me';

  // Token key for shared preferences
  static const String tokenKey = 'auth_token';
}
