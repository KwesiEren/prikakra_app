import 'package:shared_preferences/shared_preferences.dart';

//
class SharedPreferencesHelper {
  // Define keys for each field
  static const String _userEmailKey = 'user_email';
  static const String _usernameKey = 'username';
  static const String _userPasswordKey = 'user_password';
  static const String _userTeamKey = 'user_team';

  // Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  // Retrieve user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Save username
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Retrieve username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Save user password
  static Future<void> saveUserPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPasswordKey, password);
  }

  // Retrieve user password
  static Future<String?> getUserPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPasswordKey);
  }

  // Save user team
  static Future<void> saveUserTeam(String team) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTeamKey, team);
  }

  // Retrieve user team
  static Future<String?> getUserTeam() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTeamKey);
  }

  // Check if user is logged in based on email presence
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userEmailKey);
  }

  // Clear all user profile data
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userPasswordKey);
    await prefs.remove(_userTeamKey);
  }
}
