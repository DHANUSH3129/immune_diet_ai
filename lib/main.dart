import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/app_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(
    name: 'immune-diet-ai',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const ImmuneDietApp(),
    ),
  );
}

class ImmuneDietApp extends StatelessWidget {
  const ImmuneDietApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Immune Diet AI',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: const SplashScreen(),
  );
}
