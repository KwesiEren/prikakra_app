import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _userEmailKey = 'user_email';

  // Save user email to shared preferences
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  // Retrieve user email from shared preferences
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Check if user email is saved
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userEmailKey);
  }

  // Clear user session
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
  }
}
