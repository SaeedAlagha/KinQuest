import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'core/branding/app_brand.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/screens/welcome_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocaleController.instance.load();

  runApp(const SilaApp());
}

class SilaApp extends StatelessWidget {
  const SilaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, child) {
        return MaterialApp(
          title: AppBrand.fullName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
