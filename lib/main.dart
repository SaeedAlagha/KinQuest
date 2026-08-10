import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/branding/app_brand.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SilaApp());
}

class SilaApp extends StatelessWidget {
  const SilaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBrand.fullName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
