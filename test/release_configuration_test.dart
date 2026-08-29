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

    expect(infoPlist, contains('<key>NSCameraUsageDescription</key>'));
    expect(infoPlist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
    expect(infoPlist, contains('<key>NSPhotoLibraryAddUsageDescription</key>'));
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
}
