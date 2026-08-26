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
import 'features/notifications/wishlist_notification_route.dart';
import 'features/rewards/screens/reward_wishlist_negotiation_screen.dart';
import 'features/rewards/screens/rewards_hub_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
WishlistNotificationRoute? _pendingNotificationRoute;

void handleNotificationTap(RemoteMessage message) {
  final route = WishlistNotificationRoute.fromData(message.data);

  if (route == null) return;

  _openWishlistNotificationRoute(route);
}

void _openWishlistNotificationRoute(WishlistNotificationRoute route) {
  final navigator = navigatorKey.currentState;

  if (navigator == null) {
    _pendingNotificationRoute = route;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingRoute = _pendingNotificationRoute;
      if (pendingRoute != null) {
        _openWishlistNotificationRoute(pendingRoute);
      }
    });
    return;
  }

  _pendingNotificationRoute = null;

  switch (route.destination) {
    case WishlistNotificationDestination.sent:
      navigator.push(
        MaterialPageRoute(
          builder: (_) => RewardWishlistNegotiationScreen(
            familyId: route.familyId,
            proposalId: route.proposalId,
            initialSection: WishlistSection.sent,
          ),
        ),
      );
      return;
    case WishlistNotificationDestination.received:
      navigator.push(
        MaterialPageRoute(
          builder: (_) => RewardWishlistNegotiationScreen(
            familyId: route.familyId,
            proposalId: route.proposalId,
            initialSection: WishlistSection.received,
          ),
        ),
      );
      return;
    case WishlistNotificationDestination.goals:
      navigator.push(
        MaterialPageRoute(
          builder: (_) => RewardsHubScreen(highlightedGoalId: route.proposalId),
        ),
      );
      return;
  }
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
    AppearanceController.instance.load(
      ownershipScope: FirebaseAuth.instance.currentUser?.uid,
    ),
  ]);

  runApp(const SilaApp());
  FirebaseAuth.instance.authStateChanges().listen((user) {
    unawaited(AppearanceController.instance.load(ownershipScope: user?.uid));
  });
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
