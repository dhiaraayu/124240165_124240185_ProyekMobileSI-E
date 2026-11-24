import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/local_service.dart';
import '../theme.dart';
import 'order_controller.dart';
import 'ticket_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoggedIn = false.obs;
  final currentUserId = ''.obs;
  final currentUserName = ''.obs;
  final currentUserEmail = ''.obs;
  final isLoading = false.obs;

  /// Aksi yang tertunda saat user tamu menekan BUY (mis. buka checkout).
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

  /// Muat ulang data milik user (tiket & wishlist) setelah login/logout.
  void _refreshUserData() {
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().loadOrders();
    }
    if (Get.isRegistered<TicketController>()) {
      Get.find<TicketController>().refreshWishlist();
    }
  }

  void _snack(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Auth gate: kalau sudah login langsung jalankan [onSuccess],
  /// kalau belum -> buka halaman login, lalu lanjutkan setelah berhasil.
  void requireLogin({required VoidCallback onSuccess, String? message}) {
    if (isLoggedIn.value) {
      onSuccess();
      return;
    }

    _pendingAction = onSuccess;

    if (message != null && message.isNotEmpty) {
      _snack('Sign In Required', message, AppTheme.cardBg);
    }
    Get.toNamed('/login');
  }

  /// Dipanggil setelah login/register berhasil.
  void _finishAuth() {
    // Datang dari alur onboarding: tidak ada halaman tujuan sebelumnya,
    // jadi pindah ke beranda.
    final route = Get.currentRoute;
    if (route == '/welcome' ||
        route == '/auth-choice' ||
        route == '/auth-login') {
      _pendingAction = null;
      Get.offAllNamed('/root');
      return;
    }

    // Datang dari tombol BUY: tutup halaman login, lanjutkan aksi (checkout).
    final action = _pendingAction;
    _pendingAction = null;
    Get.back(closeOverlays: true);
    action?.call();
  }

  Future<bool> login(String email, String password) async {
    if (isLoading.value) return false;
    isLoading.value = true;

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      syncSession();
      _refreshUserData();

      isLoading.value = false;
      _finishAuth(); // navigasi dulu
      _snack('Welcome Back!', 'Signed in as ${user.name}', AppTheme.success);
      return true;
    } catch (e) {
      final msg = e is AuthException
          ? e.message
          : 'Something went wrong. Please try again.';
      _snack('Sign In Failed', msg, AppTheme.f1Red);
      isLoading.value = false;
      return false;
    }
  }

  /// Return true kalau berhasil. Kalau gagal karena email sudah dipakai,
  /// halaman login akan mengecek [lastRegisterEmailTaken].
  bool lastRegisterEmailTaken = false;

  Future<bool> register(String name, String email, String password) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    lastRegisterEmailTaken = false;

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      // Register hanya membuat akun. Login dilakukan secara terpisah.
    } catch (e) {
      if (e is AuthException) {
        lastRegisterEmailTaken = e.emailTaken;
        _snack('Registration Failed', e.message, AppTheme.f1Red);
      } else {
        _snack(
          'Registration Failed',
          'Something went wrong. Please try again.',
          AppTheme.f1Red,
        );
      }
      isLoading.value = false;
      return false;
    }

    isLoading.value = false;
    return true;
  }

  Future<void> logout() async {
    await _authService.logout();
    _pendingAction = null;
    syncSession();
    _refreshUserData();
    Get.offAllNamed('/root');
    _snack(
      'Signed Out',
      'You have been logged out successfully.',
      AppTheme.cardBg,
    );
  }
}
