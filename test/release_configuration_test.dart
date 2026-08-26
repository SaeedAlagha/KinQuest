import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release networking is secure and notification-ready', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.INTERNET'));
    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
  });

  test('iOS explains every photo and camera permission used by the app', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(infoPlist, contains('<key>NSCameraUsageDescription</key>'));
    expect(infoPlist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
    expect(infoPlist, contains('<key>NSPhotoLibraryAddUsageDescription</key>'));
  });
}
