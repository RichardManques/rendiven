import 'package:shared_preferences/shared_preferences.dart';
import 'package:rendiven/core/constants/api_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(ApiConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(ApiConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(ApiConstants.tokenKey);
  }

  bool get isAuthenticated => getToken() != null;
}
