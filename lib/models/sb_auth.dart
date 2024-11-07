import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/shared_preferences_helper.dart';
import 'hash_method.dart';

// The Auth codes which handle the login and signup calls to the online database.

class SBAuth {
  final AuthSB = Supabase.instance.client;
  final hasher = PasswordHasher();

  // Sign-up Function to Supabase table "user_credentials"
  Future<void> signUp(String user, String email, String password) async {
    try {
      //To encode password by hashing
      final salt = hasher.generateSalt();
      final hashedPassword = hasher.hashPassword(password, salt);

      //Parameters to insert into table "user_credentials". NB: the salt value is also recorded
      // so that the password can be decoded later in the Login Function.
      final response = await AuthSB.from('user_credentials').insert({
        'user': user,
        'email': email,
        'password': hashedPassword,
        'salt': salt, // Ensure salt is saved
      });

      await SharedPreferencesHelper.saveUsername(user);
      await SharedPreferencesHelper.saveUserEmail(email);
      await SharedPreferencesHelper.saveUserPassword(password);

      if (response.error != null) {
        throw response.error!;
      }

      print("User signed up successfully");
    } catch (e) {
      print("Sign-up Error: $e");
      // Optionally, return an error message for the UI
    }
  }

  //Login Function to the Supabase table "user_credentials"
  Future<String> login(String email, String password) async {
    try {
      //To retrieve the parameters including the salt value
      // from the table.
      final resp = await AuthSB.from('user_credentials')
          .select('password, salt, user')
          .eq('email', email)
          .single();

      final storedHashedPassword = resp['password'];
      final salt = resp['salt'];
      final hashedInputPassword = hasher.hashPassword(password, salt);
      final storeUser = resp['user'];

      //Condition to compare the passwords to test authentication.
      if (hashedInputPassword == storedHashedPassword) {
        // Save login session to shared preferences
        await SharedPreferencesHelper.saveUserEmail(email);
        await SharedPreferencesHelper.saveUserPassword(password);
        await SharedPreferencesHelper.saveUsername(storeUser); // Use the helper
        return "Login successful";
      } else {
        return "Login failed: Incorrect Credentials";
      }
    } catch (e) {
      print("Login Error: $e");
      return "Sorry No Connection";
    }
  }

  // Method to check if a user is logged in
  Future<void> logout() async {
    // Clear login session using the helper
    await SharedPreferencesHelper.clearUserSession();
    print('user logged out');
  }

  Future<bool> isLoggedIn() async {
    return await SharedPreferencesHelper.isUserLoggedIn(); // Use the helper
  }

  Future<String?> getLoggedInUserName() async {
    return await SharedPreferencesHelper.getUsername(); // Use the helper
  }

  Future<String?> getLoggedInUserEmail() async {
    return await SharedPreferencesHelper.getUserEmail(); // Use the helper
  }

  Future<String?> getLoggedInUserPassword() async {
    return await SharedPreferencesHelper.getUserPassword(); // Use the helper
  }
}
