import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/onboarding_visual.dart';

/// Pilihan setelah onboarding: Login, Register, atau Continue as Guest.
/// Semua tombol memakai halaman & mekanisme auth yang sudah ada (LoginPage +
/// AuthController); Guest hanya membuka beranda tanpa membuat sesi/akun.
class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackdrop(
            assets: ['assets/images/onboarding_1.jpg'],
            variant: 1,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  AppTheme.darkBg.withOpacity(0.85),
                  AppTheme.darkBg,
                ],
                stops: const [0.0, 0.5, 0.78],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'SINGAPORE GP 2027',
                    style: TextStyle(
                      color: AppTheme.f1Red,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Join the\nGrid',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      height: 1.0,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign in to book and manage your race passes, or explore the app as a guest.',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    text: 'Login',
                    icon: Icons.login_rounded,
                    onPressed: () =>
                        Get.toNamed('/auth-login', arguments: {'tab': 0}),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Register',
                    icon: Icons.person_add_alt_1_rounded,
                    isOutlined: true,
                    color: Colors.white,
                    onPressed: () =>
                        Get.toNamed('/auth-login', arguments: {'tab': 1}),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Get.offAllNamed('/root'),
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
