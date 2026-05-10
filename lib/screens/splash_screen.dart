import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../utils/app_theme.dart';
import 'auth_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    await provider.restoreSession();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => provider.isLoggedIn
          ? const MainScreen()
          : const AuthScreen(),
    ));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F8EF), Color(0xFFF8EDF8), Color(0xFFFDE8D8)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [BoxShadow(
                        color: AppColors.lavenderDark.withOpacity(0.18),
                        blurRadius: 32, offset: const Offset(0, 8))],
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 52))),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(children: [
                  RichText(text: TextSpan(
                    style: const TextStyle(
                        fontFamily: 'DmSerifDisplay',
                        fontSize: 34, color: AppColors.textDark,
                        height: 1.2),
                    children: const [
                      TextSpan(text: 'Immune\n'),
                      TextSpan(text: 'Diet AI',
                          style: TextStyle(color: AppColors.mintDeep)),
                    ],
                  ), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  const Text(
                    'Personalized nutrition plans to\nfuel your immune system naturally',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14,
                        color: AppColors.textMid, height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(
                    color: AppColors.mintDark, strokeWidth: 2.5),
                ]),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
