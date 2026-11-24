import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/app_user.dart';
import 'local_service.dart';

class AuthService {
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    
    // Check if email already registered
    final existingUser = LocalService.usersBox.values.cast<AppUser?>().firstWhere(
      (u) => u?.email.toLowerCase() == trimmedEmail,
      orElse: () => null,
    );

    if (existingUser != null) {
      throw Exception('Email already registered. Please sign in instead.');
    }

    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final id = 'usr_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = AppUser(
      id: id,
      name: name.trim(),
      email: trimmedEmail,
      passwordHash: hash,
      salt: salt,
    );

    await LocalService.usersBox.put(id, newUser);
    await LocalService.setSession(
      userId: newUser.id,
      userName: newUser.name,
      userEmail: newUser.email,
    );

    return newUser;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    final user = LocalService.usersBox.values.cast<AppUser?>().firstWhere(
      (u) => u?.email.toLowerCase() == trimmedEmail,
      orElse: () => null,
    );

    if (user == null) {
      throw Exception('No account found with this email.');
    }

    final computedHash = _hashPassword(password, user.salt);
    if (computedHash != user.passwordHash) {
      throw Exception('Incorrect password. Please try again.');
    }

    await LocalService.setSession(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
    );

    return user;
  }

  Future<void> logout() async {
    await LocalService.clearSession();
  }

  AppUser? getCurrentUser() {
    final uid = LocalService.currentUserId;
    if (uid == null) return null;
    return LocalService.usersBox.get(uid);
  }
}
