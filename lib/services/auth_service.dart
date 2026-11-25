import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/app_user.dart';
import 'local_service.dart';

/// Error khusus auth, supaya pesan ke user jelas dan mudah dibedakan.
class AuthException implements Exception {
  final String message;
  final bool emailTaken;

  const AuthException(this.message, {this.emailTaken = false});

  @override
  String toString() => message;
}

class AuthService {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  AppUser? _findByEmail(String email) {
    final target = email.trim().toLowerCase();
    for (final user in LocalService.usersBox.values) {
      if (user.email.toLowerCase() == target) return user;
    }
    return null;
  }

  /// Membuat akun baru dan menyimpannya ke Hive.
  /// [autoLogin] = true langsung membuat sesi login.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    bool autoLogin = false,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty) {
      throw const AuthException('Please enter your full name.');
    }
    if (!_emailRegex.hasMatch(cleanEmail)) {
      throw const AuthException('Please enter a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    if (_findByEmail(cleanEmail) != null) {
      throw const AuthException(
        'Email already registered. Please sign in instead.',
        emailTaken: true,
      );
    }

    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    final id = 'usr_${DateTime.now().microsecondsSinceEpoch}';

    final newUser = AppUser(
      id: id,
      name: cleanName,
      email: cleanEmail,
      passwordHash: hash,
      salt: salt,
    );

    await LocalService.usersBox.put(id, newUser);

    if (autoLogin) {
      await LocalService.setSession(
        userId: newUser.id,
        userName: newUser.name,
        userEmail: newUser.email,
      );
    }

    return newUser;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final user = _findByEmail(email);

    if (user == null) {
      throw const AuthException('No account found with this email.');
    }

    final computedHash = _hashPassword(password, user.salt);
    if (computedHash != user.passwordHash) {
      throw const AuthException('Incorrect password. Please try again.');
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
