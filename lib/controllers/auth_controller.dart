import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/local_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoggedIn = false.obs;
  final currentUserId = ''.obs;
  final currentUserName = ''.obs;
  final currentUserEmail = ''.obs;
  final isLoading = false.obs;

  // Stored pending action for guest detour flow
  VoidCallback? _pendingAction;

  @override
  void onInit() {
    super.onInit();
    syncSession();
  }

  void syncSession() {
    isLoggedIn.value = LocalService.isLoggedIn;
    currentUserId.value = LocalService.currentUserId ?? '';
    currentUserName.value = LocalService.currentUserName ?? '';
    currentUserEmail.value = LocalService.currentUserEmail ?? '';
  }

  // Auth Gate: Check login, if not redirect to login and resume action on success
  void requireLogin({required VoidCallback onSuccess, String? message}) {
    if (isLoggedIn.value) {
      onSuccess();
    } else {
      _pendingAction = onSuccess;
      if (message != null && message.isNotEmpty) {
        Get.snackbar(
          'Sign In Required',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1A1B26),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
      Get.toNamed('/login');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.login(email: email, password: password);
      syncSession();
      Get.snackbar(
        'Welcome Back!',
        'Signed in as ${user.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00D26A),
        colorText: Colors.white,
      );

      // Handle pending action or return
      if (_pendingAction != null) {
        final action = _pendingAction!;
        _pendingAction = null;
        Get.back(); // pop login
        action();
      } else {
        Get.back();
      }
      return true;
    } catch (e) {
      Get.snackbar(
        'Sign In Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE10600),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      syncSession();
      Get.snackbar(
        'Registration Successful!',
        'Account created for ${user.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00D26A),
        colorText: Colors.white,
      );

      if (_pendingAction != null) {
        final action = _pendingAction!;
        _pendingAction = null;
        Get.back(); // pop login
        action();
      } else {
        Get.back();
      }
      return true;
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE10600),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    syncSession();
    _pendingAction = null;
    Get.offAllNamed('/root');
    Get.snackbar(
      'Signed Out',
      'You have been logged out successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A1B26),
      colorText: Colors.white,
    );
  }
}
