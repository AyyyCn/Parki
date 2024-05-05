import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loggedInKey = 'isLoggedIn';

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }
}
