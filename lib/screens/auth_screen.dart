import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegister = true;

  // Register controllers
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl  = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _loginEmailCtrl.dispose(); _loginPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final p = context.read<AppProvider>();
    p.clearError();
    final ok = await p.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (ok && mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  Future<void> _handleLogin() async {
    final p = context.read<AppProvider>();
    p.clearError();
    final ok = await p.login(
        _loginEmailCtrl.text.trim(), _loginPassCtrl.text);
    if (ok && mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE4F7ED), Color(0xFFF5EEF8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(children: [
                const Text('🛡️', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 10),
                Text(_isRegister ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 4),
                Text(
                  _isRegister
                      ? 'Start your immunity journey today'
                      : 'Log in to continue your journey',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
            ),

            // Tab
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  _tab('Sign Up', _isRegister, () => setState(() => _isRegister = true)),
                  _tab('Log In', !_isRegister, () => setState(() => _isRegister = false)),
                ]),
              ),
            ),

            // Form
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                if (p.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(p.error!,
                        style: const TextStyle(
                            color: Color(0xFFE24B4A),
                            fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ),

                if (_isRegister) ...[
                  _field(_nameCtrl, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(_emailCtrl, 'Email Address', Icons.email_outlined,
                      type: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _passField(_passCtrl, 'Password (min 6 chars)'),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: 'Create My Account 🚀',
                    loading: p.loading,
                    onTap: _handleRegister,
                  ),
                ] else ...[
                  _field(_loginEmailCtrl, 'Email Address', Icons.email_outlined,
                      type: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _passField(_loginPassCtrl, 'Password'),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: 'Log In',
                    loading: p.loading,
                    onTap: _handleLogin,
                  ),
                ],

                const SizedBox(height: 20),
                // Firebase info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Text('🔥', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'Your data is securely stored in Firebase Authentication & Firestore.',
                      style: TextStyle(fontSize: 11,
                          color: AppColors.mintDeep, height: 1.4),
                    )),
                  ]),
                ),
              ]),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) =>
      Expanded(child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8)] : [],
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: active
                      ? AppColors.lavenderDark : AppColors.textLight)),
        ),
      ));

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: c, keyboardType: type,
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.mintDark, size: 20)),
      );

  Widget _passField(TextEditingController c, String hint) =>
      TextField(
        controller: c, obscureText: _obscure,
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline,
                color: AppColors.mintDark, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textLight, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),
      );
}
