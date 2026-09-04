import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release networking is secure and notification-ready', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.INTERNET'));
    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, contains('android.intent.action.TTS_SERVICE'));
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
  });

  test('iOS explains every photo and camera permission used by the app', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    final entitlements = File(
      'ios/Runner/Runner.entitlements',
    ).readAsStringSync();
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();

    expect(infoPlist, contains('<key>NSCameraUsageDescription</key>'));
    expect(infoPlist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
    expect(infoPlist, contains('<key>NSPhotoLibraryAddUsageDescription</key>'));
    expect(infoPlist, contains('<key>CFBundleLocalizations</key>'));
    expect(infoPlist, contains('<string>ar</string>'));
    expect(infoPlist, contains('<key>UIBackgroundModes</key>'));
    expect(infoPlist, contains('<string>remote-notification</string>'));
    expect(entitlements, contains('<key>aps-environment</key>'));
    expect(
      project,
      contains('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements'),
    );
    expect(project, contains('com.apple.Push'));
  });

  test('iOS release helper rejects placeholder or insecure releases', () {
    final script = File('tool/build_ios_release.sh').readAsStringSync();

    expect(script, contains('KINQUEST_API_BASE_URL'));
    expect(script, contains('^https://'));
    expect(script, contains('com.example.kinquest'));
    expect(script, contains('Apple Distribution'));
    expect(script, contains('flutter build ipa --release'));
  });

  test('native launch screens use the approved Sila artwork', () {
    final androidLaunch = File(
      'android/app/src/main/res/drawable/launch_background.xml',
    ).readAsStringSync();
    final android12Launch = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();
    final iosLaunch = File(
      'ios/Runner/Base.lproj/LaunchScreen.storyboard',
    ).readAsStringSync();

    expect(androidLaunch, contains('@drawable/sila_splash'));
    expect(androidLaunch, contains('#FFF8E8'));
    expect(android12Launch, contains('@drawable/sila_splash'));
    expect(android12Launch, contains('windowSplashScreenBackground'));
    expect(iosLaunch, contains('image="LaunchImage"'));
    expect(iosLaunch, contains('red="1" green="0.9725490196"'));
    expect(iosLaunch, contains('text="SILA • صِلَة"'));
    expect(iosLaunch, contains('text="Closer, one moment at a time."'));

    final launchImages = [
      File('android/app/src/main/res/drawable/sila_splash.png'),
      File('ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png'),
      File(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png',
      ),
      File(
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
      ),
    ];

    for (final image in launchImages) {
      expect(image.existsSync(), isTrue, reason: image.path);
      expect(image.lengthSync(), greaterThan(10000), reason: image.path);
    }
  });

  test('install surfaces consistently present the Sila identity', () {
    final webIndex = File('web/index.html').readAsStringSync();
    final webManifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final androidManifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final androidName = File(
      'android/app/src/main/res/values/strings.xml',
    ).readAsStringSync();
    final androidArabicName = File(
      'android/app/src/main/res/values-ar/strings.xml',
    ).readAsStringSync();
    final iosInfo = File('ios/Runner/Info.plist').readAsStringSync();

    expect(webIndex, contains('<title>Sila | صِلَة</title>'));
    expect(webIndex, contains('id="sila-launch"'));
    expect(webIndex, contains("'flutter-first-frame'"));
    expect(webIndex, contains('icons/Icon-180.png'));
    expect(webManifest['name'], 'Sila | صِلَة');
    expect(webManifest['short_name'], 'Sila');
    expect(webManifest['theme_color'], '#006B49');
    expect(webManifest['background_color'], '#FFF8E8');
    expect(androidManifest, contains('android:label="@string/app_name"'));
    expect(androidName, contains('>Sila</string>'));
    expect(androidArabicName, contains('>صِلَة</string>'));
    expect(iosInfo, contains('<string>Sila</string>'));

    for (final image in [
      File('web/favicon.png'),
      File('web/icons/Icon-180.png'),
      File('web/icons/Icon-192.png'),
      File('web/icons/Icon-512.png'),
      File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/'
        'Icon-App-1024x1024@1x.png',
      ),
    ]) {
      expect(image.existsSync(), isTrue, reason: image.path);
      expect(image.lengthSync(), greaterThan(1000), reason: image.path);
    }
  });

  test('judge web release is installable and refresh-safe', () {
    final webIndex = File('web/index.html').readAsStringSync();
    final webManifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final firebase =
        jsonDecode(File('firebase.json').readAsStringSync())
            as Map<String, dynamic>;
    final hosting = firebase['hosting'] as Map<String, dynamic>;
    final rewrites = hosting['rewrites'] as List<dynamic>;
    final headers = hosting['headers'] as List<dynamic>;
    final welcome = File(
      'lib/features/authentication/screens/welcome_screen.dart',
    ).readAsStringSync();

    expect(webIndex, contains('width=device-width'));
    expect(webIndex, contains('apple-mobile-web-app-title'));
    expect(webManifest['id'], '/');
    expect(webManifest['start_url'], '/');
    expect(webManifest['scope'], '/');
    expect(webManifest['display'], 'standalone');
    expect(hosting['public'], 'build/web');
    expect(rewrites, hasLength(1));
    expect(rewrites.single, containsPair('source', '**'));
    expect(rewrites.single, containsPair('destination', '/index.html'));
    expect(headers, hasLength(1));
    expect(headers.single, containsPair('source', '**'));
    expect(
      (headers.single as Map<String, dynamic>)['headers'].toString(),
      contains('no-cache, max-age=0, must-revalidate'),
    );
    expect(welcome, isNot(contains('CompetitionDemo')));
    expect(welcome, isNot(contains("ValueKey('competition-demo-cta')")));
  });

  test('user-facing copy and AI context no longer expose the legacy name', () {
    for (final path in [
      'lib/l10n/app_en.arb',
      'lib/l10n/app_ar.arb',
      'backend/sila_chat.js',
      'backend/server.js',
    ]) {
      final copy = File(path).readAsStringSync().toLowerCase();
      expect(copy, isNot(contains('kinquest')), reason: path);
      expect(copy, isNot(contains('kin quest')), reason: path);
      expect(copy, isNot(contains('كين كويست')), reason: path);
    }
  });
}
