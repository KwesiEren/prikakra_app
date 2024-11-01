import 'dart:convert'; // For UTF8 encoding
import 'dart:math'; // For generating random salt

import 'package:crypto/crypto.dart'; // For SHA-256 hashing

class PasswordHasher {
  // Generate a random salt for each password
  String generateSalt([int length = 16]) {
    final random = Random.secure();
    final salt = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(salt);
  }

  // Hash the password with SHA-256 and salt
  String hashPassword(String password, String salt) {
    final saltedPassword = salt + password;
    final bytes = utf8.encode(saltedPassword); // Convert to bytes
    final hash = sha256.convert(bytes); // Hash with SHA-256
    return hash.toString();
  }
}
