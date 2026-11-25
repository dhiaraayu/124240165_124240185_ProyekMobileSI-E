import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/motion.dart';

class LoginPage extends StatefulWidget {
  /// true = layar pertama saat app dibuka (ada tombol Lewati).
  final bool isWelcome;

  const LoginPage({super.key, this.isWelcome = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirm = true;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final startTab = (args is Map && args['tab'] == 1) ? 1 : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: startTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }


  void _skip() {
    // Guest: masuk ke beranda tanpa sesi login.
    Get.offAllNamed('/root');
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authCtrl = Get.find<AuthController>();

    await authCtrl.login(
      _loginEmailCtrl.text.trim(),
      _loginPasswordCtrl.text,
    );
  }

  Future<void> _submitRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final authCtrl = Get.find<AuthController>();
    final email = _regEmailCtrl.text.trim();

    final ok = await authCtrl.register(
      _regNameCtrl.text.trim(),
      email,
      _regPasswordCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      // Register sukses: akun dibuat, tetapi user belum login.
      _loginEmailCtrl.text = email;
      _loginPasswordCtrl.clear();
      _regPasswordCtrl.clear();
      _regConfirmCtrl.clear();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text(
            'Account Created Successfully!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Your account has been created. Please sign in to continue.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Continue to Sign In'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      _tabController.animateTo(0);
      return;
    }

    // Email sudah dipakai pindah ke tab Sign In dengan email terisi.
    if (authCtrl.lastRegisterEmailTaken) {
      _loginEmailCtrl.text = email;
      _loginPasswordCtrl.clear();
      _tabController.animateTo(0);
    }
  }

  // UI 

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In / Register'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: widget.isWelcome
            ? (Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Get.back(),
                  )
                : null)
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
      ),
      body: FadeSlideIn(
        offsetY: 12,
        duration: const Duration(milliseconds: 380),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabSelector(),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSignInTab(authCtrl),
                    _buildRegisterTab(authCtrl),
                  ],
                ),
              ),
              if (widget.isWelcome)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Continue Without an Account',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              'F1 Singapore GP Ticketing',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
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
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Register'),
        ],
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
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.textMuted,
                ),
              ),
              validator: (val) {
                final v = val?.trim() ?? '';
                if (v.isEmpty) return 'Enter your email';
                if (!_emailRegex.hasMatch(v)) {
                  return 'Enter a valid email';
                }
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
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.textMuted,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLoginPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                text: 'Sign In & Continue',
                isLoading: authCtrl.isLoading.value,
                onPressed: _submitLogin,
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
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppTheme.textMuted,
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Enter your full name';
                }
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
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.textMuted,
                ),
              ),
              validator: (val) {
                final v = val?.trim() ?? '';
                if (v.isEmpty) return 'Enter your email';
                if (!_emailRegex.hasMatch(v)) {
                  return 'Enter a valid email';
                }
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
                helperText: 'Minimum 6 characters',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.textMuted,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => setState(
                    () => _obscureRegPassword = !_obscureRegPassword,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regConfirmCtrl,
              obscureText: _obscureRegConfirm,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppTheme.textMuted,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureRegConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => setState(
                    () => _obscureRegConfirm = !_obscureRegConfirm,
                  ),
                ),
              ),
              validator: (val) {
                if (val != _regPasswordCtrl.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                text: 'Create Account & Continue',
                isLoading: authCtrl.isLoading.value,
                onPressed: _submitRegister,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
