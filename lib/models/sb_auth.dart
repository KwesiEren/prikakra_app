import 'package:supabase_flutter/supabase_flutter.dart';

import 'hash_method.dart';

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
