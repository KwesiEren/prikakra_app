import 'package:supabase_flutter/supabase_flutter.dart';

import 'hash_method.dart';

class SBAuth {
  final AuthSB = Supabase.instance.client;
  final hasher = PasswordHasher();

  // Sign-up Function
  Future<void> signUp(String user, String email, String password) async {
    try {
      final salt = hasher.generateSalt();
      final hashedPassword = hasher.hashPassword(password, salt);

      final response = await AuthSB.from('user_credentials').insert({
        'user': user,
        'email': email,
        'password': hashedPassword,
        'salt': salt, // Ensure salt is saved
      });

      if (response.error != null) {
        throw response.error!;
      }

      print("User signed up successfully");
    } catch (e) {
      print("Sign-up Error: $e");
      // Optionally, return an error message for the UI
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final resp = await AuthSB.from('user_credentials')
          .select('password, salt')
          .eq('email', email)
          .single();

      final storedHashedPassword = resp['password'];
      final salt = resp['salt'];
      final hashedInputPassword = hasher.hashPassword(password, salt);

      if (hashedInputPassword == storedHashedPassword) {
        return "Login successful for email: $email";
      } else {
        return "Login failed: Incorrect password";
      }
    } catch (e) {
      print("Login Error: $e");
      return "Login failed: User not found or other error";
    }
  }
}
