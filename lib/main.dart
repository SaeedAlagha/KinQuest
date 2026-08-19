import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'core/branding/app_brand.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/appearance_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/screens/welcome_screen.dart';
import 'features/rewards/screens/reward_wishlist_negotiation_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleNotificationTap(RemoteMessage message) {
  final type = message.data['type']?.toString();
  final familyId = message.data['familyId']?.toString();
  final proposalId = message.data['proposalId']?.toString();

  if (type == null || !type.startsWith('wishlist')) {
    return;
  }

  if (familyId == null ||
      familyId.isEmpty ||
      proposalId == null ||
      proposalId.isEmpty) {
    return;
  }

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => RewardWishlistNegotiationScreen(
        familyId: familyId,
        proposalId: proposalId,
      ),
    ),
  );
}

Future<void> _saveFcmTokenForUser(String userId) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();

    if (token == null || token.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('fcmTokens')
        .doc(token)
        .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
  } catch (error) {
    debugPrint('Push token registration skipped: $error');
  }
}

Future<void> _enablePushForUser(User user) async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    await _saveFcmTokenForUser(user.uid);
  } catch (error) {
    debugPrint('Push notification permission skipped: $error');
  }
}

Future<void> _initializePushNotifications() async {
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      unawaited(_enablePushForUser(user));
    }
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || newToken.isEmpty) {
      return;
    }

    unawaited(_saveFcmTokenForUser(user.uid));
  });

  FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

  try {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationTap(initialMessage);
      });
    }
  } catch (error) {
    debugPrint('Initial push notification lookup skipped: $error');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Future.wait([
    LocaleController.instance.load(),
    AppearanceController.instance.load(),
  ]);

  runApp(const SilaApp());
  unawaited(_initializePushNotifications());
}

class SilaApp extends StatelessWidget {
  const SilaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LocaleController.instance,
        AppearanceController.instance,
      ]),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: AppBrand.fullName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.forAppearance(
            AppearanceController.instance.appearance,
          ),
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
