import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_loginFormKey.currentState!.validate()) {
      final authCtrl = Get.find<AuthController>();
      authCtrl.login(
        _loginEmailCtrl.text.trim(),
        _loginPasswordCtrl.text.trim(),
      );
    }
  }

  void _submitRegister() {
    if (_registerFormKey.currentState!.validate()) {
      final authCtrl = Get.find<AuthController>();
      authCtrl.register(
        _regNameCtrl.text.trim(),
        _regEmailCtrl.text.trim(),
        _regPasswordCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('04 Sign In / Register'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.f1Red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'F1 SINGAPORE GP TICKETING',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Access Your Tickets & Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Register'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Sign In Tab
                  _buildSignInTab(authCtrl),

                  // Register Tab
                  _buildRegisterTab(authCtrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInTab(AuthController authCtrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _loginEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your email';
                if (!val.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loginPasswordCtrl,
              obscureText: _obscureLoginPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                ),
              ),
              validator: (val) {
                if (val == null || val.length < 4) return 'Password must be at least 4 characters';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(() => AppButton(
                  text: 'Sign In & Continue',
                  isLoading: authCtrl.isLoading.value,
                  onPressed: _submitLogin,
                )),
            const SizedBox(height: 20),

            // Demo Quick Fill Helper for Aslab presentation
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.bolt, color: AppTheme.gold, size: 16),
                label: const Text(
                  'Quick Fill Demo Account',
                  style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _loginEmailCtrl.text = 'fan@singaporegp.sg';
                  _loginPasswordCtrl.text = 'f1gp2027';
                  _regNameCtrl.text = 'Alex Verstappen';
                  _regEmailCtrl.text = 'fan@singaporegp.sg';
                  _regPasswordCtrl.text = 'f1gp2027';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthController authCtrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _regNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your full name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter your email';
                if (!val.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regPasswordCtrl,
              obscureText: _obscureRegPassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Create Password',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                ),
              ),
              validator: (val) {
                if (val == null || val.length < 4) return 'Password must be at least 4 characters';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(() => AppButton(
                  text: 'Create Account & Continue',
                  isLoading: authCtrl.isLoading.value,
                  onPressed: _submitRegister,
                )),
          ],
        ),
      ),
    );
  }
}
