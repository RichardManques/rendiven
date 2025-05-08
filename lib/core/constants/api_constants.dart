class ApiConstants {
  static const String baseUrl = 'http://192.168.18.145:5000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String getMe = '/auth/me';

  // Token key for shared preferences
  static const String tokenKey = 'auth_token';
}
